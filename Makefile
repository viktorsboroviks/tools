LINT_DOCKER_TAG = env_lint:latest
FIN_DOCKER_TAG = env_fin:latest
LATEX_DOCKER_TAG = env_latex:latest
RUN_PATH ?= $(PWD)
PYTHONPATH ?= $(PWD)

.PHONY: all \
	setup-githooks \
	setup-link \
	setup-fin \
	setup-latex \
	setup \
	lint \
	clean-docker \
	clean-latex \
	clean

all: setup

setup-githooks:
# setup git hooks
	git config core.hooksPath githooks

setup-lint:
	./docker/setup_env.sh ./docker/env_lint $(LINT_DOCKER_TAG)

setup-fin:
	./docker/setup_env.sh ./docker/env_fin $(FIN_DOCKER_TAG)

setup-latex:
	./docker/setup_env.sh ./docker/env_latex $(LATEX_DOCKER_TAG)

setup: setup-lint setup-fin setup-latex

lint: setup-lint
	./docker/lint.sh -v $(RUN_PATH)

clean-docker:
	./native/clean_docker.sh -v

clean-latex:
	./native/clean_latex.sh -v latex

clean: clean-latex
