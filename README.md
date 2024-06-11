# Habitica for iOS [![Build Status](https://travis-ci.org/HabitRPG/habitica-ios.svg?branch=master)](https://travis-ci.org/HabitRPG/habitica-ios)

Native iOS app for [Habitica](https://habitica.com/).

## Contributing

For an introduction to the technologies used and how the software is organized, refer to [Contributing to Habitica](http://habitica.wikia.com/wiki/Contributing_to_Habitica#Coders_.28Web_.26_Mobile.29) - "Coders (Web & Mobile)" section.

Thank you very much [to all contributors](https://github.com/HabitRPG/habitica-ios/graphs/contributors).

#### How mobile releases work

All major mobile releases are organized by Milestones labeled with the release number. The 'Help Wanted' is added to any issue we feel would be okay for a contributor to work on, so look for that tag first! We do our best to answer any questions contributors may have regarding issues marked with that tag. If an issue does not have the 'Help Wanted' tag, that means staff will handle it when we have the availability. 

The mobile team consists of one developer and one designer for both Android and iOS. Because of this, we switch back and forth for releases. While we work on one platform, the other will be put on hold. This may result in a wait time for PRs to be reviewed or questions to be answered. Any PRs submitted while we're working on a different platform will be assigned to the next Milestone and we will review it when we come back!

Given that our team is stretched pretty thin, it can be difficult for us to take an active role in helping to troubleshoot how to fix issues, but we always do our best to help as much as possible :) With this in mind, when selecting issues to work on it may be best to pick up issues you already have a good idea how to handle and test. Thank you for putting in your time to help make Habitica the best it can be!

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

During installation, cocoapods-keys will prompt for some of the keys used in the project. Use any random value for debugging, the real values are only required when uploading a final build to the app store.

CocoaPods requires that you open the *Habitica.xcworkspace*.

```
$ open Habitica.xcworkspace
```

### Non-M1 Mac Installation

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

### M1 Mac Installation

#### Step 1: Install Brew

```
# Install Brew (package manager)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add 'brew' as a terminal command (change {USER_NAME})
echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/{USER_NAME}/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify Installation
which brew
```

#### Step 2: Install cocoapods using Brew

```
brew install cocoapods

# Verify the installation from brew and get the Version number:
brew info cocoapods
# ^example output: cocoapods: stable 1.10.1 (bottled)

# Go to your project directory
cd path/to/project

# Install pods (REMEMBER to run this in your project folder)
opt/homebrew/Cellar/cocoapods/{VERSION}/bin/pod init
opt/homebrew/Cellar/cocoapods/{VERSION}/bin/pod install
```
NOTE Get the {VERSION} from the brew info cocoapods command

### Step 3: Install swiftgen and generate secrets

```
brew install swiftgen

# Replace the secrets.yml.example to secrets.yml and set your own values

swiftgen config run

NOTE You can run the project without being set the credentials but this features will be limited

```

