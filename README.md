# Habitica for iOS

This repository contains the Native iOS application for the productivity and wellness-centered web program [Habitica](https://habitica.com/) that encourages self-improvement and motivation through exciting role-playing game mechanics. 

#### Key Features:

The Habitica iOS app allows users to stay inspired on the go with these features:

* ✅ Tracking habits and complete daily tasks to stay productive 📅
* 🎮 Gamify productivity by earning XP, leveling up, and collecting rewards 🏆
* ⚔️ Team up with friends to go on quests and defeat bosses 🐉
* 🎨 Customize avatars, collect pets 🐱, and unlock cool gear 🛡️

## Contributing

#### How mobile releases work

All major mobile releases are organized by Milestones labeled with the release number. The 'Help Wanted' is added to any issue we feel would be okay for a contributor to work on, so look for that tag first! We do our best to answer any questions contributors may have regarding issues marked with that tag. If an issue does not have the 'Help Wanted' tag, that means staff will handle it when we have the availability.  When selecting issues to work on it may be best to pick up issues you already have a good idea how to handle and test.

The mobile team consists of one developer and one designer for both Android and iOS. Because of this, we switch back and forth for releases. While we work on one platform, the other will be put on hold. This may result in a wait time for PRs to be reviewed or questions to be answered. Any PRs submitted while we're working on a different platform will be assigned to the next Milestone and we will review it when we come back!

#### Production Support

Our wiki page contains resources on how to contribute code, the details of existing code and features, and also indicate where to seek further guidance or ask questions. Additionally, linked below are recommended starting resources.

* [Wiki Page for Contributing](https://habitica.fandom.com/wiki/Category:Contributing) - the general wiki page.
* [Guidance for Blacksmiths](https://habitica.fandom.com/wiki/Guidance_for_Blacksmiths) - an introduction to the technologies used and how the software is organized.
* [Setting up Habitica Locally](https://github.com/HabitRPG/habitica/wiki/Setting-Up-Habitica-for-Local-Development) - how to set up a local install of Habitica for development and testing.

#### Steps for contributing to this repository:

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create new Pull Request
* Don't forget to include your Habitica User ID, so that we can count your contributrion towards your contributor tier

#### Interested in contributing elsewhere?

* Android: https://github.com/HabitRPG/habitica-android
* Main Program: https://github.com/HabitRPG/habitica

#### Acknowledgement

Thank you very much [to all contributors](https://github.com/HabitRPG/habitica-ios/graphs/contributors).

Given that our team is stretched pretty thin, it can be difficult for us to take an active role in helping to troubleshoot how to fix issues, but we always do our best to help as much as possible :) Thank you for putting in your time to help make Habitica the best it can be!

## Setup for local development

### Getting Started

To set up and run the Habitica iOS app locally, follow these steps:

1. **Clone this repository**
   ```bash
   git clone https://github.com/HabitRPG/habitica-ios.git
   
2. **Navigate into project folder**
   ```bash
   cd habitica-ios

3. **Install dependencies**
   ```bash
   yarn install

4. **Open `Habitica.xcodeproj` in Xcode and build the project.**
   

### Config File

Copy over the sample debug config file.

```
$ cp sample.debug.xcconfig debug.xcconfig
```

If you want to run your app against a locally running version of Habitica, change `CUSTOM_DOMAIN` to `localhost:3000` or whatever port you have your local version configured to. Also set `DISABLE_SSL` to true so that the url can be configured correctly.


### Install swiftgen and generate secrets

```
brew install swiftgen

# Replace the secrets.yml.example to secrets.yml and set your own values

swiftgen config run
```

NOTE You can run the project without being set the credentials but this features will be limited

