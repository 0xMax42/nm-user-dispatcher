# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### 🐛 Bug Fixes

- *(debian)* Add bash to package dependencies - ([6afc365](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/6afc36596a0f51096db09b38f6d501880d29a046))

### 🚜 Refactor

- Add makefile and improve nm user dispatcher script - ([05f38ca](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/05f38cac4a7bec0557a034119e393cc8610d74df))

### 🧪 Testing

- Add bats tests and improve nm-user-dispatcher script - ([50322be](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/50322be538fe5df772a2246c16c4b4844626e2f3))

### ⚙️ Miscellaneous Tasks

- *(debian)* Add bash and bats-core to build dependencies - ([c6b8091](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/c6b80912c695c9a99ae7d4ec0f7911e7b0f8a98b))
- *(devcontainer)* Add vscode devcontainer for bash and bats setup - ([ad629bf](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/ad629bfeb83ca9f84ed705324fd5c8e011464f23))
- *(ci)* Add gitea workflow to run bats tests - ([d3db84d](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/d3db84d5efc29053b0b5b2d6e51d106f254e6269))
- *(debian)* Add homepage and copyright metadata - ([bf6659a](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/bf6659ac72a77187f807adc89a24738707bd8e91))
- *(ci)* Update release workflow to use debcrafter and tea-pkg - ([061d37b](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/061d37b40800bf3e6a4883e46da3d9c31a835414))
- Remove git cliff configuration file - ([5c60ae0](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/5c60ae00e00f84a8a48ef90261553636397668fa))
- *(build)* Run dpkg-buildpackage clean after moving packages - ([918ca64](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/918ca6455d0e189611100fb58ee33891e0303a55))

## [0.2.0](https://git.0xmax42.io/maxp/nm-user-dispatcher/compare/v0.1.0..v0.2.0) - 2025-11-11

### 🚀 Features

- *(debian)* Add postinst and postrm scripts for systemd user service - ([c0b0e30](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/c0b0e30c000bbe5308727d82d86eb81743e37079))

### 🐛 Bug Fixes

- *(systemd)* Update user dispatcher service dependencies - ([d07eb39](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/d07eb398cb8baba22ce3132291f5a9d77816aff7))
- *(ci)* Update artifact copy and commit patterns for nm-user-dispatcher - ([e8569b6](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/e8569b632cb6cb985ca085cf8ee57d3acdd9aa37))

## [0.1.0] - 2025-11-11

### 🚀 Features

- Add per-user NetworkManager event dispatcher and Debian packaging - ([ad28627](https://git.0xmax42.io/maxp/nm-user-dispatcher/commit/ad28627943959b464c4ae3a54a2cb3941f5c4857))


