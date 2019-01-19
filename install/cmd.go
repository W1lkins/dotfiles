package main

import (
	"os"
	"os/exec"
)

func do(dir string, command string, args ...string) error {
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
