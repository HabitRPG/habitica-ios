//
//  HRPGLoadingViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 19/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGLoadingViewController.h"
#import "HRPGAppDelegate.h"
#import "Habitica-Swift.h"

@interface HRPGLoadingViewController ()
@end

@implementation HRPGLoadingViewController

- (void)viewDidAppear:(BOOL)animated {
    if ([[AuthenticationManager shared] hasAuthentication]) {
        [self segueForLoggedInUser];
    } else {
        [self performSegueWithIdentifier:@"IntroSegue" sender:self];
    }
    [super viewDidAppear:YES];
}

- (void)segueForLoggedInUser {
    bool isInSetup = [[NSUserDefaults standardUserDefaults] boolForKey:@"isInSetup"];
    if (isInSetup) {
        [self performSegueWithIdentifier:@"SetupSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"InitialSegue" sender:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.loadingFinishedAction) {
        self.loadingFinishedAction();
    }
    [super viewDidDisappear:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        UINavigationController *navigationViewController = segue.destinationViewController;
        LoginTableViewController *loginViewController =
            (LoginTableViewController *)navigationViewController.topViewController;
        loginViewController.isRootViewController = YES;
    }
}

@end
