##
## Kiveto Mobile - thin entry point: the logic lives in scripts/ (bash 3.2).
## GNU Make 3.81 compatible (macOS /usr/bin/make): no .ONESHELL, $(file),
## != or grouped targets. Run it from Git Bash on Windows.
##

# bash resolved on PATH: a native Windows make has no /bin/bash.
SHELL := bash
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

##
## OPTIONS (make <target> NAME=value)
##
# PLATFORM and ENV are common environment variables (HP machines export
# PLATFORM): only a command-line value counts, an inherited one is ignored.
ifeq ($(origin PLATFORM),environment)
PLATFORM := android
endif
ifeq ($(origin ENV),environment)
ENV := dev
endif
# REF too (api-sync): an inherited REF is ignored. KIVETO_BACKEND_DIR, a
# name of our own, is honoured from the environment.
ifeq ($(origin REF),environment)
REF :=
endif

PLATFORM ?= android
DEVICE ?=
EMULATOR ?=
SIMULATOR ?=
ENV ?= dev
RUN_ARGS ?=
BOOT_WAIT ?= 180
V ?= 0
NO_COLOR ?=
LOG_FILE ?= .make/make.log
FULL ?= 0
REF ?=
KIVETO_BACKEND_DIR ?=

export PLATFORM DEVICE EMULATOR SIMULATOR ENV RUN_ARGS BOOT_WAIT V NO_COLOR LOG_FILE FULL REF KIVETO_BACKEND_DIR MAKE_VERSION

.PHONY: help doctor install install-fvm start devices clean reset \
	ci format format-check analyze test test-unit test-widget test-integration \
	test-tool test-architecture test-coverage coverage-gate test-scripts \
	api-sync api-generate api-check

help:
	@echo "Targets:"
	@echo "  help               this list (default)"
	@echo "  doctor             check the prerequisites and print how to fix them (read-only)"
	@echo "  install            prerequisites + pinned Flutter (FVM) + pub get + git hooks + config/env/dev.json"
	@echo "  install-fvm        install FVM 4.3.2 for the current user only (opt-in)"
	@echo "  start              run the app on a device, emulator or simulator"
	@echo "  devices            list devices, emulators (AVDs) and, on macOS, simulators"
	@echo "  clean              flutter clean + remove the .make/ stamps (the log is kept)"
	@echo "  reset              clean + install"
	@echo ""
	@echo "Quality gate:"
	@echo "  ci                 format-check, analyze, test-architecture, test-coverage, coverage-gate, test-scripts, api-check"
	@echo "  format             format lib/, test/, tool/ (fvm dart format)"
	@echo "  format-check       fail when a Dart file is not formatted"
	@echo "  analyze            fvm dart analyze --fatal-infos --fatal-warnings"
	@echo "  test               every test suite (unit, widget, integration, tool, architecture)"
	@echo "  test-unit          test/unit/"
	@echo "  test-widget        test/widget/"
	@echo "  test-integration   test/integration/ (no device)"
	@echo "  test-tool          test/tool/ (device picker, scanner, coverage gate)"
	@echo "  test-architecture  test/architecture/ (layer and feature rules)"
	@echo "  test-coverage      unit, widget, integration and tool suites with coverage (coverage/lcov.info)"
	@echo "  coverage-gate      100% of the gated layers, every file of lib/ and tool/ counted"
	@echo "  test-scripts       plain-bash checks of scripts/ and .githooks/ (test/scripts/)"
	@echo "  api-check          contracts/portal.v1.yaml, contracts/SOURCE and packages/kiveto_portal_api agree"
	@echo ""
	@echo "Portal API client (CONTRIBUTING.md section 8):"
	@echo "  api-sync           copy the backend contract at REF into contracts/, then api-generate"
	@echo "  api-generate       regenerate packages/kiveto_portal_api from the contract copy (tonik)"
	@echo ""
	@echo "Options:"
	@echo "  PLATFORM=android|ios   start: target platform (default: android; ios needs macOS)"
	@echo "  DEVICE=<id>            start: device to run on (see make devices)"
	@echo "  EMULATOR=<avd>         start: AVD to boot when no Android device runs (default: the first)"
	@echo "  SIMULATOR=<name>       start: simulator to boot when none runs (default: the first iPhone)"
	@echo "  ENV=dev                start: passes config/env/<ENV>.json with --dart-define-from-file"
	@echo "  RUN_ARGS=...           start: extra flutter run flags, e.g. RUN_ARGS=--release"
	@echo "  BOOT_WAIT=180          start: seconds to wait for the emulator or simulator to boot"
	@echo "  FULL=1                 doctor: add fvm flutter doctor -v"
	@echo "  REF=<sha>              api-sync: the backend commit to copy (required)"
	@echo "  KIVETO_BACKEND_DIR=... api-sync: the backend checkout (default ../kiveto), e.g."
	@echo "                         //wsl.localhost/<distro>/<path>/kiveto (a WSL checkout)"
	@echo "  V=1                    verbose output"
	@echo "  NO_COLOR=1             disable colors"
	@echo "  LOG_FILE=...           change log path (default: .make/make.log)"

doctor:
	@bash scripts/doctor.sh

install:
	@bash scripts/install.sh

install-fvm:
	@bash scripts/install-fvm.sh

start:
	@bash scripts/start.sh

devices:
	@bash scripts/devices.sh

clean:
	@bash scripts/clean.sh

reset:
	@$(MAKE) clean && $(MAKE) install

ci:
	@KV_TARGET=$@ MAKE='$(MAKE)' bash scripts/ci.sh

format:
	@KV_TARGET=$@ bash scripts/format.sh

format-check:
	@KV_TARGET=$@ bash scripts/format.sh --check

analyze:
	@KV_TARGET=$@ bash scripts/analyze.sh

test:
	@KV_TARGET=$@ bash scripts/test.sh

test-unit:
	@KV_TARGET=$@ bash scripts/test.sh unit

test-widget:
	@KV_TARGET=$@ bash scripts/test.sh widget

test-integration:
	@KV_TARGET=$@ bash scripts/test.sh integration

test-tool:
	@KV_TARGET=$@ bash scripts/test.sh tool

test-architecture:
	@KV_TARGET=$@ bash scripts/test.sh architecture

test-coverage:
	@KV_TARGET=$@ bash scripts/test.sh --coverage

coverage-gate:
	@KV_TARGET=$@ bash scripts/coverage-gate.sh

test-scripts:
	@KV_TARGET=$@ bash scripts/test-scripts.sh

api-sync:
	@KV_TARGET=$@ bash scripts/api.sh sync

api-generate:
	@KV_TARGET=$@ bash scripts/api.sh generate

api-check:
	@KV_TARGET=$@ bash scripts/api.sh check
