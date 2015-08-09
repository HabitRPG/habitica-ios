//
//  HRPGBBaseCollectionViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 13/07/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseCollectionViewController.h"
#import "Google/Analytics.h"
#import <PDKeychainBindings.h>
#import "HRPGAppDelegate.h"
#import "HRPGRoundProgressView.h"
#import "HRPGActivityIndicator.h"
#import "HRPGDeathView.h"
#import "HRPGTopHeaderNavigationController.h"
#import "HRPGNavigationController.h"

@interface HRPGBaseCollectionViewController ()
@end

@implementation HRPGBaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[self getScreenName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    if ([keyChain stringForKey:@"id"] == nil || [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:navigationController animated:NO completion:nil];
    }
    
    if (!self.hidesTopBar && [self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
        [self.collectionView setContentInset:UIEdgeInsetsMake([navigationController getContentOffset],0,0,0)];
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([navigationController getContentOffset],0,0,0);
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
}

- (NSString *) getScreenName {
    if (self.readableScreenName) {
        return self.readableScreenName;
    } else {
        return NSStringFromClass([self class]);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    User *user = [self.sharedManager getUser];
    if (user && [user.health floatValue] <= 0) {
        HRPGDeathView *deathView = [[HRPGDeathView alloc] init];
        [deathView show];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destViewController = segue.destinationViewController;
    if ([destViewController isKindOfClass:[HRPGNavigationController class]]) {
        HRPGNavigationController *destNavigationController = (HRPGNavigationController*)destViewController;
        destNavigationController.sourceViewController = self;
    }
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = self.sharedManager.getManagedObjectContext;
    }
    return _managedObjectContext;
}


@end
