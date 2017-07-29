//
//  HRPGBaseViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import <Google/Analytics.h>
#import "Amplitude.h"
#import "HRPGAppDelegate.h"
#import "HRPGDeathView.h"
#import "HRPGNavigationController.h"
#import "HRPGTopHeaderNavigationController.h"
#import "UIViewController+TutorialSteps.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"

@interface HRPGBaseViewController ()
@property UIBarButtonItem *navigationButton;
@end

@implementation HRPGBaseViewController

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

    if (self.topHeaderNavigationController) {
        [self.tableView
            setContentInset:UIEdgeInsetsMake([self.topHeaderNavigationController getContentInset], 0, 0, 0)];
        self.tableView.scrollIndicatorInsets =
            UIEdgeInsetsMake([self.topHeaderNavigationController getContentInset], 0, 0, 0);
        if (self.topHeaderNavigationController.state == HRPGTopHeaderStateHidden) {
            [self.tableView
                setContentOffset:CGPointMake(0, -[self.topHeaderNavigationController getContentOffset])];
        }
    }

    self.viewWidth = self.view.frame.size.width;
}

- (NSString *)getScreenName {
    if (self.readableScreenName) {
        return self.readableScreenName;
    } else {
        return NSStringFromClass([self class]);
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)viewWillLayoutSubviews {
    CGFloat newWidth = self.view.frame.size.width;
    if (self.viewWidth != newWidth) {
        self.viewWidth = newWidth;
        [self.tableView reloadData];
    }
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
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

    if (self.topHeaderNavigationController) {
        if (self.tableView.contentOffset.y < -[self.topHeaderNavigationController getContentOffset]) {
            [self.tableView setContentOffset:CGPointMake(0, 0)];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    User *user = [self.sharedManager getUser];
    if (user && user.health && [user.health floatValue] <= 0) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HRPGDeathView" owner:self options:nil];
        HRPGDeathView *deathView = (HRPGDeathView *)[nib objectAtIndex:0];
        [deathView show];
    }

    [self displayTutorialStep:self.sharedManager];

    if (self.topHeaderNavigationController) {
        [self.topHeaderNavigationController startFollowingScrollView:self.tableView];
        if (self.topHeaderNavigationController.state == HRPGTopHeaderStateVisible &&
            self.tableView.contentOffset.y > -[self.topHeaderNavigationController getContentOffset]) {
            [self.topHeaderNavigationController scrollview:self.tableView
                                        scrolledToPosition:self.tableView.contentOffset.y];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.topHeaderNavigationController) {
        [self.topHeaderNavigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.topHeaderNavigationController) {
        [self.topHeaderNavigationController stopFollowingScrollView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.displayedTutorialStep = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    // Skeletton method, so that it can be referenced from IB
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    // Skeletton method, so that it can be referenced from IB
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destViewController = segue.destinationViewController;
    if ([destViewController isKindOfClass:[HRPGNavigationController class]]) {
        HRPGNavigationController *destNavigationController =
            (HRPGNavigationController *)destViewController;
        destNavigationController.sourceViewController = self;
    }
}

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath {
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.item == indexPath.item && index.section == indexPath.section) {
            return YES;
        }
    }
    return NO;
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

- (HRPGTopHeaderNavigationController *)topHeaderNavigationController {
    return [self hrpgTopHeaderNavigationController];
}

@end
