# W1lkins dotfiles

Installation instructions:

---

1. Clone the repository using `git clone https://github.com/W1lkins/dotfiles.git`
2. cd to the repository with `cd dotfiles`
3. Run the bootstrap shell script with `./bootstrap` (You may need to run `chmod 755 bootstrap`)
4. Fill in your Github details
5. If you're on OSX press `y` to install brew and some sane packages/defaults (Look in the macos folder for what will be
   run)
6. ???
7. Profit

---

Testing without installing (using Docker):

1. Clone the repo as above
2. Run `make build create start install attach`
3. You'll now be in a Docker container running ubuntu with `zsh`, `vim`, & `shellcheck` installed
4. If you want to run shellcheck on the `.sh` files run `testscripts` from the `/project` directory
5. If you want to test without booting into a docker container just run `make test`

---

Enjoy
