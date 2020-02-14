#!/bin/bash
echo "Applying system and application defaults..."
osascript -e 'tell application "System Preferences" to quit'

# System

echo "System - Disable the 'Are you sure you want to open this application?' dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "System - Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "System - Disable smart quotes (not useful when writing code)"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "System - Disable smart dashes (not useful when writing code)"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "System - Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "System - Automatically restart if system freezes"
sudo systemsetup -setrestartfreeze on

# Keyboard

echo "Keyboard - Enable keyboard access for all controls"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Trackpad

echo "Trackpad - Enable tap to click for current user and the login screen"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Bluetooth

echo "Bluetooth - Increase sound quality for headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Dock

echo "Dock - Automatically hide and show"
defaults write com.apple.dock autohide -bool true

echo "Dock - Remove the auto-hiding delay"
defaults write com.apple.Dock autohide-delay -float 0

echo "Dock - Don’t show Dashboard as a Space"
defaults write com.apple.dock "dashboard-in-overlay" -bool true

# Finder

echo "Finder - Show the $HOME/Library folder"
chflags nohidden "$HOME"/Library

echo "Finder - Show hidden files"
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "Finder - Show filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder - Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Finder - Show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "Finder - Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "Finder - Display full POSIX path as window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "Finder - Use list view in all Finder windows"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

echo "Finder - Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

echo "Finder - Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

# Time Machine                                                                #

echo "Time Machine - Don't ask to use new hard drives"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "Time Machine - Disable local backups"
hash tmutil &> /dev/null && sudo tmutil disablelocal

# Mac App Store

echo "Mac App Store - Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true

echo "Mac App Store - Enable the automatic update check"
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "Mac App Store - Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Mac App Store - Download newly available updates in background"
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "Mac App Store - Install System data files & security updates"
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

echo "Mac App Store - Automatically download apps purchased on other Macs"
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

echo "Mac App Store - Turn on app auto-update"
defaults write com.apple.commerce AutoUpdate -bool true

# VSCode

echo "VSCode - Allow key repeat with Vim Mode"
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false

# TweetBot

echo "TweetBot - Bypass t.co slowness"
sudo defaults write com.tapbots.TweetbotMac OpenURLsDirectly -bool true

if ! type brew &> /dev/null; then
    echo "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing brew stuff..."
brew bundle --file=macos/Brewfile
