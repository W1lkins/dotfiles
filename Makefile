NAME := install.sh
SHELLCHECK := ./bin.sym/test-dotfile-scripts
.DEFAULT_GOAL := install
DIR := $(shell pwd)

.PHONY: all
all: update init ## runs update and init

.PHONY: update
update: ## update from GitHub
	@echo "+ $@"
	@git pull origin master

.PHONY: install
install: ## run the dotfile install script
	@echo "+ $@"
	./$(NAME)

.PHONY: test
test: ## run the tests if there are any && shellcheck
	@echo "+ $@"
	$(SHELLCHECK)

.PHONY: init
init: ## run the dotfile install script with init
	@echo "+ $@"
	./$(NAME) init

.PHONY: docker
docker: docker-build docker-create docker-start docker-setup docker-attach ## build docker file and attach
	@echo "+ $@"

.PHONY: docker-build
docker-build:
	@echo "+ $@"
	docker build --tag dotfiles --rm - < docker.sym/dotfiletest/Dockerfile

.PHONY: docker-create
docker-create: docker-stop docker-clean ## stop dotfile container, remove, and recreate
	@echo "+ $@"
	docker create --interactive --tty \
		--name dotfiles \
		--hostname dotfiles \
		--env	IS_SERVER=1 \
		--volume $(DIR):/dotfiles \
		dotfiles \
		/bin/zsh --login

.PHONY: docker-start
docker-start: ## start dotfile container
	@echo "+ $@"
	@docker start dotfiles > /dev/null 2>&1

.PHONY: docker-stop
docker-stop:
	@echo "+ $@"
	@docker stop dotfiles > /dev/null 2>&1 ||:

.PHONY: docker-setup
docker-setup: ## run make in dotfile container
	@echo "+ $@"
	@docker exec --interactive --tty dotfiles make

.PHONY: docker-attach
docker-attach: ## attach to running dotfile container
	@echo "+ $@"
	@docker exec --interactive --tty dotfiles /bin/zsh --login ||:

.PHONY: docker-clean
docker-clean: docker-stop ## stop and clean dotfile container
	@echo "+ $@"
	@docker rm dotfiles > /dev/null 2>&1 ||:

.PHONY: docker-destroy
docker-destroy: docker-clean ## stop and remove dotfile container, remove built image
	@echo "+ $@"
	@docker rmi dotfiles > /dev/null 2>&1 ||:

.PHONY: help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

