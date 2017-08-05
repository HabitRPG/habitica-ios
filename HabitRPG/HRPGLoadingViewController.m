//
//  HRPGLoadingViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 19/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGLoadingViewController.h"
#import "PDKeychainBindings.h"
#import "Habitica-Swift.h"

@interface HRPGLoadingViewController ()
@end

@implementation HRPGLoadingViewController

- (void)viewDidAppear:(BOOL)animated {
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    if ([keyChain stringForKey:@"id"] == nil ||
        [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"IntroSegue" sender:self];
    } else {
        if ([[HRPGManager sharedManager] getUser].username.length == 0) {
            self.activityIndicator.alpha = 1;
            [self.activityIndicator startAnimating];
            [[HRPGManager sharedManager] fetchUser:^() {
                [self performSegueWithIdentifier:@"InitialSegue" sender:self];
            }
                onError:^() {
                    [self performSegueWithIdentifier:@"InitialSegue" sender:self];
                }];
        } else {
            [self segueForLoggedInUser];
        }
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
