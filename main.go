package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"

	"github.com/mitchellh/go-homedir"
	"github.com/sirupsen/logrus"
	"github.com/tcnksm/go-input"
)

// Help banner
const (
	BANNER = `
 _____        _    __ _ _  
|  __ \      | |  / _(_) |  
| |  | | ___ | |_| |_ _| | ___  ___  
| |  | |/ _ \| __|  _| | |/ _ \/ __|  
| |__| | (_) | |_| | | | |  __/\__ \  
|_____/ \___/ \__|_| |_|_|\___||___/  

Set up dotfiles for the current system
Build: %s
    `
)

var (
	debug bool
	vrsn  bool
)

var gitcommit string

func init() {
	// parse flags
	flag.BoolVar(&vrsn, "version", false, "print version and exit")
	flag.BoolVar(&vrsn, "v", false, "print version and exit (shorthand)")
	flag.BoolVar(&debug, "d", false, "run in debug mode")

	flag.Usage = func() {
		fmt.Fprint(os.Stderr, fmt.Sprintf(BANNER, gitcommit))
		flag.PrintDefaults()
	}

	flag.Parse()

	if vrsn {
		fmt.Fprint(os.Stderr, fmt.Sprintf(BANNER, gitcommit))
		os.Exit(0)
	}

	if debug {
		logrus.SetLevel(logrus.DebugLevel)
	}
}

func main() {
	format := new(logrus.TextFormatter)
	format.DisableTimestamp = true
	logrus.SetFormatter(format)

	// handle exit
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	signal.Notify(c, syscall.SIGTERM)
	go func() {
		for s := range c {
			logrus.Infof("received %s, exiting.", s.String())
			os.Exit(0)
		}
	}()

	setupGitConfig()
	moveDotfiles()
	setupVim()

	logrus.Info("install complete")
}

func setupGitConfig() {
	wd, err := os.Getwd()
	if err != nil {
		logrus.Fatalf("could not get working directory %v", err)
	}

	home, err := homedir.Dir()
	if err != nil {
		logrus.Fatalf("could not get home directory %v", err)
	}

	gcfg := home + "/.gitconfig"
	if !fileExists(gcfg) {
		logrus.Info("setting up gitconfig")
		store := "cache"
		if runtime.GOOS == "darwin" {
			store = "osxkeychain"
		}

		name := askUser("What is your Github author name?", &input.Options{
			Default:  "W1lkins",
			Required: true,
			Loop:     true,
		})

		email := askUser("What is your Github author email?", &input.Options{
			Default:  "wilkins@linux.com",
			Required: true,
			Loop:     true,
		})

		useGPG := askUser("Do you want to use a GPG key with git? [y/N]", &input.Options{
			Default:  "N",
			Required: true,
			Loop:     true,
		})

		usingGPG := strings.HasPrefix(strings.ToLower(useGPG), "y")

		var key string
		if usingGPG {
            err := runCommand(wd, "gpg", "--list-secret-keys", "--keyid-format", "LONG")
            if err != nil {
                logrus.Fatalf("could not list gpg secret keys: %v", err)
            }
			key = askUser("Which key?", &input.Options{
				Required: true,
				Loop:     true,
			})
		}

		localFile := "./git/gitconfig"
		if !fileExists("./git/gitconfig") {
			logrus.Fatal("could not find ./git/gitconfig")
		}

		err := copyFile(localFile, gcfg)
		if err != nil {
			logrus.Fatalf("could not copy %s to %s: %v", localFile, gcfg, err)
		}

		// replace placeholder values
		read, err := ioutil.ReadFile(gcfg)
        if err != nil {
            logrus.Fatalf("could not read file %s: %v", gcfg, err)
        }
		new := strings.Replace(string(read), "AUTHORNAME", name, -1)
		new = strings.Replace(new, "AUTHOREMAIL", email, -1)
		new = strings.Replace(new, "GIT_CREDENTIAL_HELPER", store, -1)
		if usingGPG {
			new = strings.Replace(new, "AUTHORGPGKEY", key, -1)
			new = strings.Replace(new, "gpgsign = false", "gpgsign = true", -1)
		}

        err = ioutil.WriteFile(gcfg, []byte(new), 0)
		if err != nil {
			logrus.Fatalf("could not replace contents of file %s: %v", gcfg, err)
		}

		logrus.Info("gitconfig created")
	} else {
		logrus.Info("skipped gitconfig")
	}
}

func moveDotfiles() {
	logrus.Info("installing dotfiles")

	files := getFilesWithExtension(".sym")
	home, err := homedir.Dir()
	if err != nil {
		logrus.Fatalf("could not get home directory: %v", err)
	}

	for _, f := range files {
		s := strings.Replace(f, ".sym", "", -1)
		d := home + "/." + strings.Replace(s, "./", "", -1)
		abs, err := filepath.Abs(f)
		if err != nil {
			logrus.Fatalf("could not get absolute path of %s: %v", f, err)
		}
		linkFile(abs, d)
	}
}

func setupVim() {
	logrus.Info("setting up vim")
    err := runCommand("./vim.sym", "vim", "+PlugInstall", "+qa")
    if err != nil {
        logrus.Fatalf("could not run PlugInstall: %v", err)
    }
	logrus.Info("plugins installed")

	if !fileExists("vim.sym/bundle/command-t/ruby/command-t/ext/command-t/ext.bundle") {
		logrus.Info("setting up command-t")
        // we don't care if this fails
        _ = runCommand("./vim.sym/bundle/command-t", "rake", "make")
	}

	logrus.Info("vim setup complete")
}

func linkFile(src, dst string) {
	skip := false

	if fileExists(dst) {
		if !isSymlink(dst) {
			logrus.Infof("file already exists: %s, what to do?", dst)
			choice := askUser("[s]kip, [o]verwrite, [b]ackup?", &input.Options{
				Default:  "s",
				Required: true,
				Loop:     true,
				ValidateFunc: func(s string) error {
					if s != "s" && s != "o" && s != "b" {
						return fmt.Errorf("answer must be one of: s | o | b")
					}
					return nil
				},
			})

			switch choice {
			case "s":
				logrus.Infof("skipped %s", dst)
				skip = true
			case "o":
				err := os.Remove(dst)
				if err != nil {
					logrus.Fatalf("could not remove %s: %v", dst, err)
				}
				logrus.Infof("removed %s", dst)
			case "b":
				err := os.Rename(dst, dst+".backup")
				if err != nil {
					logrus.Fatalf("could not rename %s: %v", dst, err)
				}
				logrus.Infof("moved %s to %s.backup", dst, dst)
			}
		} else {
			logrus.Infof("skipped %s", dst)
			skip = true
		}
	}

	if !skip {
		logrus.Debugf("symlinking %s to %s", src, dst)
		err := os.Symlink(src, dst)
		if err != nil {
			logrus.Fatalf("failed to symlink %s to %s: %v", src, dst, err)
		}
		logrus.Infof("linked %s to %s", src, dst)
	}
}

func getFilesWithExtension(ext string) []string {
	path, err := os.Getwd()
	if err != nil {
		logrus.Fatalf("could not get current working dir: %v", err)
	}

	var files []string
	filepath.Walk(path, func(p string, f os.FileInfo, _ error) error {
		if filepath.Ext(p) == ext && !strings.Contains(f.Name(), "git") {
			if !strings.Contains(f.Name(), "%") {
				files = append(files, "./"+f.Name())
			}
		}
		return nil
	})

	return files
}

func fileExists(f string) bool {
	_, err := os.Stat(f)
	return !os.IsNotExist(err)
}

func isSymlink(f string) bool {
	b, err := os.Lstat(f)
	if err != nil {
		logrus.Fatalf("could not determine whether or not %s is a symlink: %v", f, err)
	}
	return b.Mode()&os.ModeSymlink == os.ModeSymlink
}

func askUser(query string, opt *input.Options) string {
	ui := input.DefaultUI()

	o, err := ui.Ask(query, opt)
	if err != nil {
		logrus.Fatalf("error while asking %s, %v", query, err)
	}

	return o
}

func runCommand(dir string, command string, args ...string) error {
	cmd := exec.Command(command, args...)
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	cmd.Stdout = os.Stdout

	cmd.Dir = dir
	err := cmd.Run()
	if err != nil {
        return err
	}

    return nil
}

func copyFile(src, dst string) error {
	from, err := os.Open(src)
	if err != nil {
		return err
	}
	defer from.Close()

	to, err := os.OpenFile(dst, os.O_RDWR|os.O_CREATE, 0664)
	if err != nil {
		return err
	}
	defer to.Close()

	_, err = io.Copy(to, from)
	if err != nil {
		return err
	}

	return nil
}
