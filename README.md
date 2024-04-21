> [!CAUTION]
> The versions included in this tap no longer build on Scons 4.2 (or higher). Likewise, newer versions of NSIBI no longer build on macOS at all.

# homebrew-nsisbi

[![BSD 2-Clause License](https://flat.badgen.net/badge/license/BSD%202-Clause/blue)](https://opensource.org/licenses/BSD-2-Clause)
[![Latest Release](https://flat.badgen.net/github/release/idleberg/homebrew-nsisbi)](https://github.com/idleberg/homebrew-nsisbi/releases)
[![Travis](https://flat.badgen.net/travis/idleberg/homebrew-nsisbi)](https://travis-ci.org/idleberg/homebrew-nsisbi)
[![David](https://flat.badgen.net/david/dev/idleberg/homebrew-nsisbi)](https://david-dm.org/idleberg/homebrew-nsisbi?type=dev)

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
