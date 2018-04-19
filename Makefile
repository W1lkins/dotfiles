BOOTSTRAP=./bootstrap.pl
DBUILD=$(DOCKERCMD) build
DCREATE=$(DOCKERCMD) create
DEXEC=$(DOCKERCMD) exec
DOCKERCMD=docker
DRM=$(DOCKERCMD) rm
DRMI=$(DOCKERCMD) rmi
DSTART=$(DOCKERCMD) start
DSTOP=$(DOCKERCMD) stop
GITCMD=git
GITPULL=$(GITCMD) pull
LINT=perl -cw bootstrap.pl
SHELLCHECK=./scripts.sym/testscripts

.PHONY: all
all: setup 

.PHONY: docker
docker: 
	@echo "+ $@"
	build create start install attach ## build a docker file and attach

.PHONY: setup
setup: ## pull from git and run the bootstrap install script
	@echo "+ $@"
	$(GITCMD) pull origin master && $(BOOTSTRAP)

.PHONY: build
build: ## build from dockerfile and tag as dotfiles
	@echo "+ $@"
	docker build --tag dotfiles --rm - < docker.sym/dotfiletest/Dockerfile

.PHONY: create
create: ## stop dotfile container, remove, and recreate
	@echo "+ $@"
	$(DSTOP) dotfiles > /dev/null 2>&1 ||:
	$(DRM) dotfiles > /dev/null 2>&1 ||:
	$(DCREATE) --interactive --tty \
		--name dotfiles \
		--hostname dotfiles \
		--volume ${HOME}/dotfiles:/project \
		dotfiles \
		/bin/zsh --login

.PHONY: start
start: ## start dotfile container
	@echo "+ $@"
	$(DSTART) dotfiles

.PHONY: stop
stop: ## stop dotfile container
	@echo "+ $@"
	$(DSTOP) dotfiles

.PHONY: install
install: ## run bootstrap.pl inside docker
	@echo "+ $@"
	$(DEXEC) --interactive --tty dotfiles \
		$(BOOTSTRAP) \
		--config=zsh \
		--minimal

.PHONY: test
test: ## lint and shellcheck
	@echo "+ $@"
	$(LINT) && $(SHELLCHECK)

.PHONY: attach
attach: ## attach to a dotfile container
	@echo "+ $@"
	$(DEXEC) --interactive --tty dotfiles \
		/bin/zsh --login ||:

.PHONY: clean
clean: ## stop and remove dotfile container
	@echo "+ $@"
	$(DSTOP) dotfiles > /dev/null 2>&1 ||:
	$(DRM) dotfiles > /dev/null 2>&1 ||:

.PHONY: destroy
destroy: clean ## stop and remove dotfile container, remove built image
	@echo "+ $@"
	$(DRMI) dotfiles > /dev/null 2>&1 ||:

.PHONY: up
up: setup ## alias for setup

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.SILENT:
