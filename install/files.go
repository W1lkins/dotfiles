package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	homedir "github.com/mitchellh/go-homedir"
	"github.com/sirupsen/logrus"
	input "github.com/tcnksm/go-input"
)

// LinkFiles finds .sym files and symlinks them in $HOME
func LinkFiles() {
	logrus.Info("installing dotfiles")

	files := getFilesWithExtension(".sym")
	if len(files) == 0 {
		logrus.Fatalf("Found no files with .sym extension")
	}
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

		link(abs, d)
	}
}

func link(src, dst string) {
	skip := false

	if exists(dst) {
		if isSymlink(dst) {
			logrus.Infof("skipped %s", dst)
			return
		}
		logrus.Infof("file already exists: %s, what to do?", dst)
		choice := AskUser("[s]kip, [o]verwrite, [b]ackup?", &input.Options{
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

func isSymlink(f string) bool {
	b, err := os.Lstat(f)
	if err != nil {
		logrus.Fatalf("could not determine whether or not %s is a symlink: %v", f, err)
	}

	return b.Mode()&os.ModeSymlink == os.ModeSymlink
}

func exists(f string) bool {
	_, err := os.Stat(f)
	return !os.IsNotExist(err)
}

func makeCopy(src, dst string) error {
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
