package main

import (
	"context"
	"flag"
	"os"
	"os/signal"
	"syscall"

	"github.com/genuinetools/pkg/cli"
	"github.com/sirupsen/logrus"
)

var debug bool

func main() {
	p := cli.NewProgram()
	p.Name = "dotfiles"
	p.Description = "Install W1lkins dotfiles"
	p.GitCommit = GITCOMMIT
	p.Version = VERSION

	p.FlagSet = flag.NewFlagSet("dotfiles", flag.ExitOnError)
	p.FlagSet.BoolVar(&debug, "d", false, "enable debug logging")
	p.FlagSet.BoolVar(&debug, "debug", false, "enable debug logging")

	p.Before = func(ctx context.Context) error {
		format := new(logrus.TextFormatter)
		format.DisableTimestamp = true
		logrus.SetFormatter(format)

		if debug {
			logrus.SetLevel(logrus.DebugLevel)
		}

		return nil
	}

	p.Action = func(ctx context.Context, args []string) error {
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

		logrus.Debugf("running system setup")
		run()

		logrus.Debugf("setup complete")
		return nil
	}

	p.Run()
}

func run() error {
	SetupGit()
	LinkFiles()
	SetupVim()

	return nil
}
