# HabitRPG for iOS

Native iOS app for [HabitRPG](https://habitrpg.com/).

## Setup for local development

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

