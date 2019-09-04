SHELL := /bin/bash
SOURCERY = Pods/Sourcery/bin/sourcery
APPUNITE-CACHE = ~/appunite-cache
BINARIES_FOLDER=/usr/local/bin
TEMPORARY_FOLDER = ./tmp
SWIFT_BUILD_FLAGS=--configuration release

USE_SWIFT_STATIC_STDLIB:=$(shell test -d $$(dirname $$(xcrun --find swift))/../lib/swift_static/macosx && echo yes)
ifeq ($(USE_SWIFT_STATIC_STDLIB), yes)
SWIFT_BUILD_FLAGS+= -Xswiftc -static-stdlib
endif

FIBS_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/fibs
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
	@swift build -c release --disable-sandbox

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
	install "$(FIBS_EXECUTABLE)" "$(BINARIES_FOLDER)"

zip: install
	mkdir -p "$(TEMPORARY_FOLDER)/"
	cp -f "$(BINARIES_FOLDER)/fibs" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "fibs" "LICENSE.md") > "./fibs.zip"

help:    ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
