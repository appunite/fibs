SHELL := /bin/bash
SOURCERY = Pods/Sourcery/bin/sourcery
APPUNITE-CACHE = ~/appunite-cache
BINARIES_FOLDER=/usr/local/bin
TEMPORARY_FOLDER = ./tmp
SWIFT_BUILD_FLAGS=--configuration release
EXECUTABLE_FOLDER=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)
BINARY_NAME=fibs
LIB_AGENTCORE_DYLIB_NAME=libagentcore.dylib
LIB_CPUPLUGIN_DYLIB_NAME=libcpuplugin.dylib
LIB_ENVPLUGIN_DYLIB_NAME=libenvplugin.dylib
LIB_HCAPLUGIN_DYLIB_NAME=libhcapiplugin.dylib
LIB_MEMPLUGIN_DYLIB_NAME=libmemplugin.dylib
BINARY_EXECUTABLE=$(EXECUTABLE_FOLDER)/$(BINARY_NAME)
LIB_AGENTCORE_DYLIB=$(EXECUTABLE_FOLDER)/$(LIB_AGENTCORE_DYLIB_NAME)
LIB_CPUPLUGIN_DYLIB=$(EXECUTABLE_FOLDER)/$(LIB_CPUPLUGIN_DYLIB_NAME)
LIB_ENVPLUGIN_DYLIB=$(EXECUTABLE_FOLDER)/$(LIB_ENVPLUGIN_DYLIB_NAME)
LIB_HCAPLUGIN_DYLIB=$(EXECUTABLE_FOLDER)/$(LIB_HCAPLUGIN_DYLIB_NAME)
LIB_MEMPLUGIN_DYLIB=$(EXECUTABLE_FOLDER)/$(LIB_MEMPLUGIN_DYLIB_NAME)
LICENSE_PATH="$(shell pwd)/LICENSE.md"
GIT_TAG=$(shell git describe --tags --abbrev=0)

define PODSPEC_CONTENTS
{
  "name": "Fibs",
  "version": "$(GIT_TAG)",
  "summary": "Mock endpoints & execute commands",
  "description": "Library for mocking network traffic and executing shell commands locally from running app.",
  "homepage": "https://git.appunite.com/szymon.mrozek/fibs",
  "license": {
    "type": "MIT",
    "file": "LICENSE.md"
  },
  "authors": {
    "Damian Kolasiński": "damian.kolasinski@appunite.com",
    "Szymon Mrozek": "szymon.mrozek.sm@gmail.com"
  },
  "source": {
    "http": "https://git.appunite.com/szymon.mrozek/fibs/-/jobs/$(CI_JOB_ID)/artifacts/raw/fibs.zip"
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
	@test -s Pods/ || bundle exec pod install || make cocoapods-fresh

generate-project:	## Genetate xcode project and bootstrap swift dependencies
	@echo "--- Resolving swift dependencies..."
	@swift package resolve
	@echo "--- Generating xcode project..."
	@swift package generate-xcodeproj --xcconfig-overrides Sources/Configuration/Common.xcconfig

gems:	## Bootstrap gems dependencies
	@gem install bundler
	@echo "--- Installing gems..."
	@bundle install --path vendor/bundle

build-release:  ## Build with release configuration
	@swift build $(SWIFT_BUILD_FLAGS)
	@install_name_tool -change $(LIB_AGENTCORE_DYLIB) @loader_path/$(LIB_AGENTCORE_DYLIB_NAME) $(BINARY_EXECUTABLE)
	@install_name_tool -change $(LIB_CPUPLUGIN_DYLIB) @loader_path/$(LIB_CPUPLUGIN_DYLIB_NAME) $(BINARY_EXECUTABLE)
	@install_name_tool -change $(LIB_ENVPLUGIN_DYLIB) @loader_path/$(LIB_ENVPLUGIN_DYLIB_NAME) $(BINARY_EXECUTABLE)
	@install_name_tool -change $(LIB_HCAPLUGIN_DYLIB) @loader_path/$(LIB_HCAPLUGIN_DYLIB_NAME) $(BINARY_EXECUTABLE)
	@install_name_tool -change $(LIB_MEMPLUGIN_DYLIB) @loader_path/$(LIB_MEMPLUGIN_DYLIB_NAME) $(BINARY_EXECUTABLE)

cocoapods-fresh:    ## update repository and then try to instal pods
	@echo "--- Updating cocoapods repos..."
	@bundle exec pod repo update
	@bundle exec pod install

sourcery: ## Meta - code generator
	@$(SOURCERY) --sources Sources/ --templates AutoMockable.stencil --output Tests/ApplicationTests/Mocks/AutoMockable.generated.swift --disableCache

restore-cache:	## store cache in aws
	@$(APPUNITE-CACHE) restore --keys 'pods-{{ checksum "Podfile.lock" }}'
	@$(APPUNITE-CACHE) restore --keys 'gems-{{ checksum "Gemfile.lock" }}'

store-cache:	## restore cache from aws
	@$(APPUNITE-CACHE) store --key 'pods-{{ checksum "Podfile.lock" }}' --paths 'Pods'
	@$(APPUNITE-CACHE) store --key 'gems-{{ checksum "Gemfile.lock" }}' --paths 'vendor'

install: build-release	## Install binaries in local bin path
	install -d "$(BINARIES_FOLDER)"
	install "$(BINARY_EXECUTABLE)" "$(BINARIES_FOLDER)"
	install "$(LIB_AGENTCORE_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_HCAPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_CPUPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_ENVPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_MEMPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"

zip: install	## Zip all binaries into embeded zip file
	mkdir -p "$(TEMPORARY_FOLDER)/"
	cp -f "$(BINARIES_FOLDER)/$(BINARY_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_AGENTCORE_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_CPUPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_ENVPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_HCAPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_MEMPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "$(BINARY_NAME)" $(LIB_AGENTCORE_DYLIB_NAME) $(LIB_CPUPLUGIN_DYLIB_NAME) $(LIB_CPUPLUGIN_DYLIB_NAME) $(LIB_ENVPLUGIN_DYLIB_NAME) $(LIB_HCAPLUGIN_DYLIB_NAME) $(LIB_MEMPLUGIN_DYLIB_NAME) "LICENSE.md") > "./$(BINARY_NAME).zip"

generate-podspec:	## Generate podspec file
	@echo "$$PODSPEC_CONTENTS" > Fibs.podspec.json

release-cocoapods:	## Release new version to cocoapods repo
	@bundle exec pod trunk push

help:    ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
