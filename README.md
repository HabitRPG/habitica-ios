# Habitica for iOS [![Build Status](https://travis-ci.org/HabitRPG/habitica-ios.svg?branch=master)](https://travis-ci.org/HabitRPG/habitica-ios)

Native iOS app for [Habitica](https://habitica.com/).

## Setup for local development

### Config File

Copy over the sample debug config file.

```
$ cp sample.debug.xcconfig debug.xcconfig
```

If you want to run your app against a locally running version of Habitica, change `CUSTOM_DOMAIN` to `localhost:3000` or whatever port you have your local version configured to. Also set `DISABLE_SSL` to true so that the url can be configured correctly.

### CocoaPods

We are using [CocoaPods](http://cocoapods.org) to manage dependencies.

If you have managed ruby environment (rbenv, rvm, etc.):

```
$ bundle install
$ bundle exec pod install
```

As an alternative, it is possible to install the dependendencies manually. Use `sudo` if required to install gems (i.e. you are using the MacOS system ruby):

```
$ sudo gem install cocoapods:'>=1.2'
$ sudo gem install cocoapods-keys
$ pod install
```

During installation, cocoapods-keys will prompt for some of the keys used in the project. Use any random value for debugging, the real values are only required when uploading a final build to the app store.

CocoaPods requires that you open the *Habitica.xcworkspace*.

```
$ open Habitica.xcworkspace
```

