//
//  HRPGBBaseCollectionViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 13/07/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseCollectionViewController.h"
#import <PDKeychainBindings.h>
#import "Amplitude.h"
#import "Google/Analytics.h"
#import "HRPGAppDelegate.h"
#import "HRPGDeathView.h"
#import "HRPGNavigationController.h"
#import "HRPGTopHeaderNavigationController.h"
#import "UIViewcontroller+TutorialSteps.h"

@interface HRPGBaseCollectionViewController ()

@end

@implementation HRPGBaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[self getScreenName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:@"pageview" forKey:@"hitType"];
    [eventProperties setValue:[self getScreenName] forKey:@"page"];
    [[Amplitude instance] logEvent:@"navigate" withEventProperties:eventProperties];

    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    if ([keyChain stringForKey:@"id"] == nil ||
        [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navigationController =
            [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:navigationController animated:NO completion:nil];
    }

    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        [self.collectionView
            setContentInset:UIEdgeInsetsMake([navigationController getContentInset], 0, 0, 0)];
        self.collectionView.scrollIndicatorInsets =
            UIEdgeInsetsMake([navigationController getContentInset], 0, 0, 0);
        if (navigationController.state == HRPGTopHeaderStateHidden) {
            [self.collectionView
                setContentOffset:CGPointMake(0, -[navigationController getContentOffset])];
        }
    }

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
}

- (NSString *)getScreenName {
    if (self.readableScreenName) {
        return self.readableScreenName;
    } else {
        return NSStringFromClass([self class]);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        if (navigationController.state == HRPGTopHeaderStateHidden &&
            self.collectionView.contentOffset.y <
                self.collectionView.contentInset.top - [navigationController getContentOffset]) {
            [self.collectionView
                setContentOffset:CGPointMake(0, -[navigationController getContentOffset])];
        } else if (navigationController.state == HRPGTopHeaderStateVisible) {
            [navigationController scrollview:self.collectionView
                          scrolledToPosition:self.collectionView.contentOffset.y];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    User *user = [self.sharedManager getUser];
    if (user && user.health && [user.health floatValue] <= 0) {
        HRPGDeathView *deathView = [[HRPGDeathView alloc] init];
        [deathView show];
    }
    [self displayTutorialStep:self.sharedManager];

    HRPGTopHeaderNavigationController *navigationController =
        (HRPGTopHeaderNavigationController *)self.navigationController;
    [navigationController startFollowingScrollView:self.collectionView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    HRPGTopHeaderNavigationController *navigationController =
        (HRPGTopHeaderNavigationController *)self.navigationController;
    [navigationController stopFollowingScrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        [navigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destViewController = segue.destinationViewController;
    if ([destViewController isKindOfClass:[HRPGNavigationController class]]) {
        HRPGNavigationController *destNavigationController =
            (HRPGNavigationController *)destViewController;
        destNavigationController.sourceViewController = self;
    }
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate =
            (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
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
