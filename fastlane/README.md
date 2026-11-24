fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs the unit tests

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload a staff build to TestFlight for internal testers only

### ios betapublic

```sh
[bundle exec] fastlane ios betapublic
```

Upload a beta build to TestFlight and distribute it to the external testers

### ios release

```sh
[bundle exec] fastlane ios release
```

Deploy a new version to the App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
