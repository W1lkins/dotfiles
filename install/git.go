package main

import (
	"io/ioutil"
	"os"
	"runtime"
	"strings"

	homedir "github.com/mitchellh/go-homedir"
	"github.com/sirupsen/logrus"
	input "github.com/tcnksm/go-input"
)

// SetupGit sets up the git config
func SetupGit() {
	wd, err := os.Getwd()
	if err != nil {
		logrus.Fatalf("could not get working directory %v", err)
	}

	home, err := homedir.Dir()
	if err != nil {
		logrus.Fatalf("could not get home directory %v", err)
	}

	gcfg := home + "/.gitconfig"
	if !exists(gcfg) {
		logrus.Info("setting up gitconfig")
		store := "cache"
		if runtime.GOOS == "darwin" {
			store = "osxkeychain"
		}

		name := AskUser("What is your Github author name?", &input.Options{
			Default:  "W1lkins",
			Required: true,
			Loop:     true,
		})

		email := AskUser("What is your Github author email?", &input.Options{
			Default:  "wilkins@linux.com",
			Required: true,
			Loop:     true,
		})

		useGPG := AskUser("Do you want to use a GPG key with git? [y/N]", &input.Options{
			Default:  "N",
			Required: true,
			Loop:     true,
		})

		usingGPG := strings.HasPrefix(strings.ToLower(useGPG), "y")

		var key string
		if usingGPG {
			err := do(wd, "gpg", "--list-secret-keys", "--keyid-format", "LONG")
			if err != nil {
				logrus.Fatalf("could not list gpg secret keys: %v", err)
			}
			key = AskUser("Which key?", &input.Options{
				Required: true,
				Loop:     true,
			})
		}

		localFile := "./git/gitconfig"
		if !exists("./git/gitconfig") {
			logrus.Fatal("could not find ./git/gitconfig")
		}

		err := makeCopy(localFile, gcfg)
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
