# Habitica for iOS [![Build Status](https://travis-ci.org/HabitRPG/habitica-ios.svg?branch=master)](https://travis-ci.org/HabitRPG/habitica-ios)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FHabitRPG%2Fhabitica-ios.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FHabitRPG%2Fhabitica-ios?ref=badge_shield)

Native iOS app for [Habitica](https://habitica.com/).

## Contributing

For an introduction to the technologies used and how the software is organized, refer to [Contributing to Habitica](http://habitica.wikia.com/wiki/Contributing_to_Habitica#Coders_.28Web_.26_Mobile.29) - "Coders (Web & Mobile)" section.

Thank you very much [to all contributors](https://github.com/HabitRPG/habitica-ios/graphs/contributors).

#### Steps for contributing to this repository:

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create new Pull Request
* Don't forget to include your Habitica User ID, so that we can count your contributrion towards your contributor tier

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



## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FHabitRPG%2Fhabitica-ios.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FHabitRPG%2Fhabitica-ios?ref=badge_large)