SHELL := /bin/bash
SOURCERY = Pods/Sourcery/bin/sourcery
BINARIES_FOLDER=/usr/local/bin
TEMPORARY_FOLDER = ./tmp
SWIFT_BUILD_FLAGS=--configuration release
EXECUTABLE_FOLDER=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)
BINARY_NAME=fibs
BINARY_EXECUTABLE=$(EXECUTABLE_FOLDER)/$(BINARY_NAME)
LICENSE_PATH="$(shell pwd)/LICENSE.md"
GIT_CURRENT_TAG=$(shell git describe --abbrev=0 --tags)

define PODSPEC_CONTENTS
{
  "name": "Fibs",
  "version": "$(GIT_CURRENT_TAG)",
  "summary": "Mock endpoints & execute commands",
  "description": "Library for mocking network traffic and executing shell commands locally from running app.",
  "homepage": "https://github.com/appunite/fibs",
  "license": {
    "type": "MIT",
    "file": "LICENSE.md"
  },
  "authors": {
    "Damian Kolasiński": "damian.kolasinski@appunite.com",
    "Szymon Mrozek": "szymon.mrozek.sm@gmail.com"
  },
  "source": {
	"http": "https://github.com/appunite/fibs/releases/download/$(GIT_CURRENT_TAG)/fibs.zip"
  },
  "preserve_paths": "*",
  "exclude_files": "**/file.zip",
  "platforms": {
    "osx": null,
    "ios": null,
    "tvos": null,
    "watchos": null
  }
}
endef
export PODSPEC_CONTENTS

bootstrap:    ## Bootstrap Gems and CocoaPods and SPM Dependencies
	@make generate-project

	@make gems

	@echo "--- Installing pods..."
	bundle exec pod check || bundle exec pod install || make cocoapods-fresh

generate-project:	## Genetate xcode project and bootstrap swift dependencies
	@echo "--- Resolving swift dependencies..."
	swift package resolve
	@echo "--- Generating xcode project..."
	swift package generate-xcodeproj --xcconfig-overrides Sources/Configuration/Common.xcconfig

gems:	## Bootstrap gems dependencies
	gem install bundler -v 2.0.2
	@echo "--- Installing gems..."
	bundle check || bundle install

build-release:  ## Build with release configuration
	swift build $(SWIFT_BUILD_FLAGS)

cocoapods-fresh:    ## update repository and then try to instal pods
	@echo "--- Updating cocoapods repos..."
	bundle exec pod repo update
	bundle exec pod install

sourcery: ## Meta - code generator
	$(SOURCERY) --sources Sources/ --templates AutoMockable.stencil --output Tests/ApplicationTests/Mocks/AutoMockable.generated.swift --disableCache

install: ## Install binaries in local bin path
	install -d "$(BINARIES_FOLDER)"
	install "$(BINARY_EXECUTABLE)" "$(BINARIES_FOLDER)"

zip: install	## Zip all binaries into embeded zip file
	mkdir -p "$(TEMPORARY_FOLDER)/"
	cp -f "$(BINARIES_FOLDER)/$(BINARY_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "$(BINARY_NAME)" "LICENSE.md") > "./$(BINARY_NAME).zip"

generate-podspec:	## Generate podspec file
	@echo "$$PODSPEC_CONTENTS" > Fibs.podspec.json

release-cocoapods:	## Release new version to cocoapods repo
	bundle exec pod trunk push --allow-warnings

help:    ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
