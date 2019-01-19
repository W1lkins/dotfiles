package main

import "github.com/sirupsen/logrus"

// SetupVim sets up .vim and handles plugin installation
func SetupVim() {
	logrus.Info("setting up vim")
	err := do("./vim.sym", "vim", "+PlugInstall", "+qa")
	if err != nil {
		logrus.Fatalf("could not run PlugInstall: %v", err)
	}
	logrus.Info("plugins installed")

	if !exists("vim.sym/bundle/command-t/ruby/command-t/ext/command-t/ext.bundle") {
		logrus.Info("setting up command-t")
		// we don't care if this fails
		_ = do("./vim.sym/bundle/command-t", "rake", "make")
	}

	logrus.Info("vim setup complete")
}
