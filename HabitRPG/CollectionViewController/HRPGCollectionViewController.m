//
//  HRPGCollectionViewController.m
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCollectionViewController.h"
#import "HRPGTopHeaderNavigationController.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Amplitude+HRPGHelpers.h"
#import "Google/Analytics.h"
#import "HRPGManager.h"
#import "HRPGDeathView.h"

@interface HRPGCollectionViewController ()
@end

@implementation HRPGCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[Amplitude instance] logNavigateEventForClass:NSStringFromClass([self class])];
    
    if (self.topHeaderNavigationController) {
        UIEdgeInsets insets = UIEdgeInsetsMake([self.topHeaderNavigationController getContentInset], 0, 0, 0);
        self.collectionView.contentInset = insets;
        self.collectionView.scrollIndicatorInsets = insets;
        if (self.topHeaderNavigationController.state == HRPGTopHeaderStateHidden) {
            self.collectionView.contentOffset =
                CGPointMake(0, -[self.topHeaderNavigationController getContentOffset]);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.topHeaderNavigationController) {
        CGFloat y = self.collectionView.contentOffset.y;
        CGFloat top = self.collectionView.contentInset.top;
        if (self.topHeaderNavigationController.state == HRPGTopHeaderStateHidden &&
            y < top - [self.topHeaderNavigationController getContentOffset]) {
            self.collectionView.contentOffset =
                CGPointMake(0, -[self.topHeaderNavigationController getContentOffset]);
        } else if (self.topHeaderNavigationController.state == HRPGTopHeaderStateVisible) {
            [self.topHeaderNavigationController scrollview:self.collectionView
                                        scrolledToPosition:y];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.topHeaderNavigationController startFollowingScrollView:self.collectionView];
    
    User *user = [[HRPGManager sharedManager] getUser];
    if (user && user.health && user.health.floatValue <= 0) {
        [[HRPGDeathView new] show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topHeaderNavigationController stopFollowingScrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.topHeaderNavigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
}

- (HRPGTopHeaderNavigationController *)topHeaderNavigationController {
    return [self hrpgTopHeaderNavigationController];
}

@end
