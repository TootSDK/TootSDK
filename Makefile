.PHONY: help test build checklint lint

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


test: ## Run unit tests
	@swift test

build: ## Build the library
	@swift build

checklint: ## Checks the project for linting errors, used by the CI
	@swift format lint --strict --configuration ./.swift-format -r .

lint: ## Applies all auto-correctable lint issues and reformats all source files
	@swift format --configuration ./.swift-format -r -i .
