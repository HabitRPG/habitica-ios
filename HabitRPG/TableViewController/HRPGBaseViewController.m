//
//  HRPGBaseViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "Amplitude+HRPGHelpers.h"
#import "UIViewController+TutorialSteps.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"

@interface HRPGBaseViewController ()
@property UIBarButtonItem *navigationButton;
@end

@implementation HRPGBaseViewController

- (void)viewDidLoad {
    self.topHeaderCoordinator = [[TopHeaderCoordinator alloc] initWithTopHeaderNavigationController:self.topHeaderNavigationController scrollView:self.tableView];
    [super viewDidLoad];
    [self populateText];

    [[Amplitude instance] logNavigateEventForClass:NSStringFromClass([self class])];

    [self.topHeaderCoordinator viewDidLoad];
    
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
    self.isVisible = YES;
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

    [self.topHeaderCoordinator viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self displayTutorialStep];
    [self.topHeaderCoordinator viewDidAppear];
}

- (void)populateText {
    
}
    
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.topHeaderCoordinator scrollViewDidScroll];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.isVisible = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    [super viewWillDisappear:animated];
    [self.topHeaderCoordinator viewWillDisappear];
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

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath {
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.item == indexPath.item && index.section == indexPath.section) {
            return YES;
        }
    }
    return NO;
}

- (UINavigationController<TopHeaderNavigationControllerProtocol> *)topHeaderNavigationController {
    return [self hrpgTopHeaderNavigationController];
}

@end
