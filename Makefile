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

bootstrap:    ## Bootstrap Gems and CocoaPods and SPM Dependencies
	@make generate-project

	@make gems

	@echo "--- Installing pods..."
	@test -s Pods/ || bundle exec pod install || make cocoapods-fresh

generate-project:	## Genetate xcode project and bootstrap swift dependencies
	@echo "--- Resolving swift dependencies..."
	@swift package resolve
	@echo "--- Generating xcode project..."
	@swift package generate-xcodeproj # --xcconfig-overrides Sources/Configuration/Common.xcconfig

gems:	## Bootstrap gems dependencies
	@gem install bundler
	@echo "--- Installing gems..."
	@bundle install --path vendor/bundle

build-release: ## Build with release configuration
	@swift build $(SWIFT_BUILD_FLAGS)

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

install:
	install -d "$(BINARIES_FOLDER)"
	install "$(BINARY_EXECUTABLE)" "$(BINARIES_FOLDER)"
	install "$(LIB_AGENTCORE_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_HCAPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_CPUPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_ENVPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"
	install "$(LIB_MEMPLUGIN_DYLIB)" "$(BINARIES_FOLDER)"

zip: install
	mkdir -p "$(TEMPORARY_FOLDER)/"
	cp -f "$(BINARIES_FOLDER)/$(BINARY_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_AGENTCORE_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_CPUPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_ENVPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_HCAPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(BINARIES_FOLDER)/$(LIB_MEMPLUGIN_DYLIB_NAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "$(BINARY_NAME)" $(LIB_AGENTCORE_DYLIB_NAME) $(LIB_CPUPLUGIN_DYLIB_NAME) $(LIB_CPUPLUGIN_DYLIB_NAME) $(LIB_ENVPLUGIN_DYLIB_NAME) $(LIB_HCAPLUGIN_DYLIB_NAME) $(LIB_MEMPLUGIN_DYLIB_NAME) "LICENSE.md") > "./fibs.zip"

help:    ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
