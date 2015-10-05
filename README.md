# HabitRPG for iOS

Native iOS app for [HabitRPG](https://habitrpg.com/).

## Setup for local development

### Config File

Copy over the sample debug config file.

```
$ cp sample.debug.xcconfig debug.xcconfig
```

If you want to run your app against a locally running version of Habitica, change `CUSTOM_DOMAIN` to `localhost:3000` or whatever port you have your local version configured to. Also set `DISABLE_SSL` to true so that the url can be configured correctly.

### Cocoapods

We are using [Cocoapods](http://cocoapods.org) to manage dependencies.

If you have managed ruby environment (rbenv, rvm, etc.):

```
$ bundle install
$ bundle exec pod install
```

If you require `sudo` to install gems (i.e. you are using the MacOS
system ruby):

```
$ sudo gem install cocoapods
$ pod install
```

CocoaPods requires that you open the *Habitica.xcworspace*.

```
$ open Habitica.xcworkspace
```

