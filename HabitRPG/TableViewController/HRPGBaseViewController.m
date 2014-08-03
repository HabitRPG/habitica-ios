//
//  HRPGBaseViewController.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "HRPGManager.h"
#import <PDKeychainBindings.h>
#import "HRPGAppDelegate.h"
#import "HRPGRoundProgressView.h"
#import "HRPGBallActivityIndicator.h"
#import "HRPGDeathView.h"

@interface HRPGBaseViewController ()
@property HRPGManager *sharedManager;
@property UIBarButtonItem *navigationButton;
@end

@implementation HRPGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = self.sharedManager.getManagedObjectContext;

    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];

    if ([keyChain stringForKey:@"id"] == nil || [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:navigationController animated:NO completion:nil];
    }
    
    self.activityCounter = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
    
    if (self.refreshControl.isRefreshing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            [self.refreshControl endRefreshing];
        });
    }
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    User *user = [self.sharedManager getUser];
    if (user && [user.health integerValue] <= 0) {
        HRPGDeathView *deathView = [[HRPGDeathView alloc] init];
        [deathView show];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

-(void)addActivityCounter {
    if (self.activityCounter == 0) {
        self.navigationButton = self.navigationItem.rightBarButtonItem;
        //HRPGRoundProgressView *indicator = [[HRPGRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        //indicator.strokeWidth = 2;
        //[indicator beginAnimating];
        HRPGBallActivityIndicator *indicator = [[HRPGBallActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [indicator beginAnimating];
        UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:indicator];
        [self.navigationItem setRightBarButtonItem:indicatorButton animated:NO];
    }
    self.activityCounter++;
}

- (void)removeActivityCounter {
    self.activityCounter--;
    if (self.activityCounter == 0) {
        [self.navigationItem setRightBarButtonItem:self.navigationButton animated:NO];
    } else if (self.activityCounter < 0) {
        self.activityCounter = 0;
    }
}

@end
