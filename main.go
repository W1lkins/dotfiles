package main

import (
    "bytes"
	"flag"
    "fmt"
    "io"
    "io/ioutil"
    "os"
    "os/exec"
	"os/signal"
    "runtime"
    "strings"
	"syscall"

	"github.com/sirupsen/logrus"
    "github.com/mitchellh/go-homedir"
    input "github.com/tcnksm/go-input"
)

const (
    BANNER = `
blaat

Set up dotfiles for the current system
Build: %s
    `
)

var (
    debug bool
    vrsn bool
)

var GITCOMMIT string

func init() {
	// parse flags
	flag.BoolVar(&vrsn, "version", false, "print version and exit")
	flag.BoolVar(&vrsn, "v", false, "print version and exit (shorthand)")
	flag.BoolVar(&debug, "d", false, "run in debug mode")

	flag.Usage = func() {
		fmt.Fprint(os.Stderr, fmt.Sprintf(BANNER, GITCOMMIT))
		flag.PrintDefaults()
	}

	flag.Parse()

	if vrsn {
		fmt.Printf("dotfiles, build %s", GITCOMMIT)
	}

	if debug {
		logrus.SetLevel(logrus.DebugLevel)
	}
}

func main() {
	// handle exit
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	signal.Notify(c, syscall.SIGTERM)
	go func() {
		for s := range c {
			logrus.Infof("Received %s, exiting.", s.String())
			os.Exit(0)
		}
	}()

    setupGitConfig()
}

func setupGitConfig() {
    home, err := homedir.Dir()
    if err != nil {
        logrus.Fatalf("Could not get home directory %s", err)
    }

    gcfg := home + "/.gitconfig"
    if (!fileExists(gcfg)) {
        logrus.Info("Setting up gitconfig")
        store := "cache"
        if runtime.GOOS == "darwin"{
            store = "osxkeychain"
        }

        name := askUser("What is your Github author name?", &input.Options{
            Default: "W1lkins",
            Required: true,
            Loop: true,
        })

        email := askUser("What is your Github author email?", &input.Options{
            Default: "wilkins@linux.com",
            Required: true,
            Loop: true,
        })

        useGPG := askUser("Do you want to use a GPG key with git? [y/N]", &input.Options{
            Default: "N",
            Required: true,
            Loop: true,
        })

        usingGPG := strings.HasPrefix(strings.ToLower(useGPG), "y")

        var key string
        if (usingGPG) {
            keys, err := runCommand("gpg", "--list-secret-keys", "--keyid-format", "LONG")
            if err != nil {
                logrus.Fatalf("Could not get GPG keys: %s", err)
            }
            logrus.Info(keys.String())

            key = askUser("Which key?", &input.Options{
                Required: true,
                Loop: true,
            })
        }

        localFile := "./git/gitconfig"
        if (!fileExists("./git/gitconfig")) {
            logrus.Fatal("Could not find ./git/gitconfig")
        }

        err := copyFile(localFile, gcfg)
        if err != nil {
            logrus.Fatalf("Could not copy %s to %s: %s", localFile, gcfg, err)
        }

        // replace placeholder values
        read, err := ioutil.ReadFile(gcfg)
        new := strings.Replace(string(read), "AUTHORNAME", name, -1)
        new = strings.Replace(new, "AUTHOREMAIL", email, -1)
        new = strings.Replace(new, "GIT_CREDENTIAL_HELPER", store, -1)
        if (usingGPG) {
            new = strings.Replace(new, "AUTHORGPGKEY", key, -1)
            new = strings.Replace(new, "gpgsign = false", "gpgsign = true", -1)
        }

        err = ioutil.WriteFile(gcfg, []byte(new), 0)
        if err != nil {
            logrus.Fatalf("Could not replace contents of file %s: %s", gcfg, err)
        }

        logrus.Info("gitconfig created")
    } else {
        logrus.Info("skipped gitconfig")
    }
}

func fileExists(f string) bool {
    _, err := os.Stat(f)
    return !os.IsNotExist(err)
}

func askUser(query string, opt *input.Options) string {
    ui := input.DefaultUI()

    o, err := ui.Ask(query, opt)
    if err != nil {
        logrus.Fatalf("Error while asking %s, %s", query, err)
    }

    return o
}

func runCommand(command string, args ...string) (bytes.Buffer, error) {
	cmd := exec.Command(command, args...)
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr

    var out bytes.Buffer
	cmd.Stdout = &out

    err := cmd.Run()
	if err != nil {
		return out, err
	}

	return out, nil
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



















