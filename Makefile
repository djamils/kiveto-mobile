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

export PLATFORM DEVICE EMULATOR SIMULATOR ENV RUN_ARGS BOOT_WAIT V NO_COLOR LOG_FILE FULL MAKE_VERSION

.PHONY: help doctor install install-fvm start devices clean reset

help:
	@echo "Targets:"
	@echo "  help            this list (default)"
	@echo "  doctor          check the prerequisites and print how to fix them (read-only)"
	@echo "  install         prerequisites + pinned Flutter (FVM) + pub get + config/env/dev.json"
	@echo "  install-fvm     install FVM 4.3.2 for the current user only (opt-in)"
	@echo "  start           run the app on a device, emulator or simulator"
	@echo "  devices         list devices, emulators (AVDs) and, on macOS, simulators"
	@echo "  clean           flutter clean + remove the .make/ stamps (the log is kept)"
	@echo "  reset           clean + install"
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
