# homebrew-nsisbi

[![BSD 2-Clause License](https://img.shields.io/github/license/idleberg/homebrew-nsisbi?style=for-the-badge)](https://opensource.org/licenses/BSD-2-Clause)
[![Build](https://img.shields.io/github/actions/workflow/status/idleberg/homebrew-nsisbi/audit.yml?style=for-the-badge)](https://github.com/idleberg/homebrew-nsisbi/actions)

Homebrew tap for [NSISBI](https://sourceforge.net/projects/nsisbi), a fork of Nullsoft Scriptable Install System with support for big installers

## Prerequisites

Make sure that [Homebrew](https://brew.sh/) is installed with `brew` in your `PATH` environmental variable

## Installation

Tap this repository in order to be able to install its formulae

```sh
$ brew tap idleberg/nsisbi
```

## Usage

You can now install any version of `nsisbi` using the command `brew install nsisbi@<version>`

```sh
# Install latest version
$ brew install nsisbi

# Install specific version
$ brew install nsisbi@3.01.1
```

To switch between versions (including standard NSIS), use the  command `brew link nsisbi@<version>`

```sh
$ brew link nsisbi@3.01.1
```

### Options

#### `--with-advanced-logging`

Enable [advanced logging](https://nsis.sourceforge.io/Special_Builds#Advanced_logging) of all installer actions

#### `--with-large-strings`

Build makensis so installers can handle [large strings](https://nsis.sourceforge.io/Special_Builds#Large_strings) (>1024 characters)

#### `--with-debug`

Build executables with debugging information.

**Note:** This is not meant for use in production!

## License

This work is licensed under the [BSD 2-Clause License](LICENSE)
