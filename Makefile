# nm-user-dispatcher Makefile
# Provides DESTDIR-aware install/uninstall targets.

.PHONY: all build test clean install uninstall help

PREFIX ?= /usr
DESTDIR ?=
LIBEXECDIR := $(PREFIX)/libexec
SYSTEMD_USERDIR := $(PREFIX)/lib/systemd/user
DATADIR := $(PREFIX)/share

SRC_DISPATCHER := scripts/nm-user-dispatcher
SRC_SERVICE := systemd/nm-user-dispatcher.service
SRC_VERSION := VERSION

DST_DISPATCHER := $(LIBEXECDIR)/nm-user-dispatcher
DST_SERVICE := $(SYSTEMD_USERDIR)/nm-user-dispatcher.service
DST_VERSION := $(DATADIR)/nm-user-dispatcher/VERSION

all: build

help:
	@echo "Available targets:"
	@echo "  install      Install files into DESTDIR"
	@echo "  uninstall    Remove installed files from DESTDIR"
	@echo "  build        No-op"
	@echo "  test         No-op"
	@echo "  clean        No-op"

build:
	@:

test:
	@if command -v bats >/dev/null 2>&1; then \
		bats tests; \
	else \
		echo "bats not found; install bats-core to run tests" >&2; \
		exit 1; \
	fi

clean:
	@:

install: build
	install -d "$(DESTDIR)$(LIBEXECDIR)"
	install -d "$(DESTDIR)$(SYSTEMD_USERDIR)"
	install -d "$(DESTDIR)$(DATADIR)/nm-user-dispatcher"
	install -m 0755 "$(SRC_DISPATCHER)" "$(DESTDIR)$(DST_DISPATCHER)"
	install -m 0644 "$(SRC_SERVICE)" "$(DESTDIR)$(DST_SERVICE)"
	install -m 0644 "$(SRC_VERSION)" "$(DESTDIR)$(DST_VERSION)"

uninstall:
	rm -f "$(DESTDIR)$(DST_DISPATCHER)"
	rm -f "$(DESTDIR)$(DST_SERVICE)"
	rm -f "$(DESTDIR)$(DST_VERSION)"
	-rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(DATADIR)/nm-user-dispatcher" 2>/dev/null || true
