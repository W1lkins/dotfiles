package main

import (
	"github.com/sirupsen/logrus"
	input "github.com/tcnksm/go-input"
)

// AskUser prompts the user for an answer to a question
func AskUser(query string, opt *input.Options) string {
	ui := input.DefaultUI()

	o, err := ui.Ask(query, opt)
	if err != nil {
		logrus.Fatalf("error while asking %s, %v", query, err)
	}

	return o
}
