//
//  HRPGGemHeaderNavigationController.m
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGGemHeaderNavigationController.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGGemHeaderNavigationController ()
@property(nonatomic, strong) UIView *headerView;
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIView *upperBackgroundView;
@property(nonatomic, readonly) CGFloat topHeaderHeight;
@property(nonatomic, strong) UISegmentedControl *segmentedControl;

- (CGFloat)statusBarHeight;
- (CGFloat)bgViewOffset;
- (CGFloat)bgHiddenPosition;

@property UIScrollView *scrollableView;
@property UIPanGestureRecognizer *gestureRecognizer;
@property CGFloat headerYPosition;
@property(nonatomic) TopHeaderState state;

@end

@implementation HRPGGemHeaderNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
    
    UIImageView *headerImageView = [[UIImageView alloc] init];
    headerImageView.image = [UIImage imageNamed:@"support_art"];
    headerImageView.contentMode = UIViewContentModeCenter;
    self.headerView = headerImageView;
    self.state = TopHeaderStateVisible;
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
    
    self.upperBackgroundView = [[UIView alloc] init];
    [self.upperBackgroundView setBackgroundColor:ObjcThemeWrapper.contentBackgroundColor];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[objcL10n.subscription, objcL10n.gems]];
    [self.segmentedControl sizeToFit];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                         action:@selector(viewControllerChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [self.backgroundView addSubview:self.headerView];
    [self.backgroundView addSubview:self.segmentedControl];
    [self.view insertSubview:self.upperBackgroundView belowSubview:self.navigationBar];
    [self.view insertSubview:self.backgroundView belowSubview:self.upperBackgroundView];
    
    self.headerYPosition = [self bgViewOffset];
    
    [[PurchaseHandler shared] completionHandler];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect segmentedFrame = self.segmentedControl.frame;
    CGRect parentFrame = self.view.frame;
    self.backgroundView.frame =
    CGRectMake(0, self.headerYPosition, parentFrame.size.width, self.topHeaderHeight+self.segmentControlHeight);
    self.upperBackgroundView.frame = CGRectMake(0, 0, parentFrame.size.width, [self bgViewOffset]);
    self.headerView.frame = CGRectMake(0, 0, parentFrame.size.width, self.topHeaderHeight);
    CGFloat segmentOffset = (parentFrame.size.width-segmentedFrame.size.width)/2;
    self.segmentedControl.frame = CGRectMake(segmentOffset, self.topHeaderHeight, segmentedFrame.size.width, segmentedFrame.size.height);
}

- (void)showHeader {
    self.state = TopHeaderStateVisible;
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = [self bgViewOffset];
    self.headerYPosition = frame.origin.y;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         self.backgroundView.frame = frame;
                     }
                     completion:^(BOOL completed){
                     }];
}

- (void)hideHeader {
    self.state = TopHeaderStateHidden;
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = self.bgHiddenPosition;
    self.headerYPosition = frame.origin.y;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         self.backgroundView.frame = frame;
                     }
                     completion:^(BOOL completed){
                     }];
}

- (void)startFollowingScrollView:(UIScrollView *)scrollView {
    if (self.scrollableView) {
        [self stopFollowingScrollView];
    }
    
    self.scrollableView = scrollView;
}

- (void)stopFollowingScrollView {
    [self.scrollableView removeGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer = nil;
    self.scrollableView = nil;
}

- (void)scrollview:(UIScrollView *)scrollView scrolledToPosition:(CGFloat)position {
    if (self.scrollableView != scrollView) {
        return;
    }
    CGRect frame = self.backgroundView.frame;
    CGFloat newYPos = -position - frame.size.height;
    if (newYPos > self.bgViewOffset) {
        newYPos = self.bgViewOffset;
    } else if (newYPos < self.bgHiddenPosition) {
        newYPos = self.bgHiddenPosition;
    }
    if ((newYPos + frame.size.height) > self.bgHiddenPosition) {
        [self setState:TopHeaderStateVisible];
    } else {
        if (self.state == TopHeaderStateHidden) {
            return;
        }
        [self setState:TopHeaderStateHidden];
    }
    frame.origin = CGPointMake(frame.origin.x, newYPos);
    self.headerYPosition = frame.origin.y;
    self.backgroundView.frame = frame;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.navigationBar.barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

- (CGFloat)topHeaderHeight {
        return 100;
}

- (CGFloat)segmentControlHeight {
    return self.segmentedControl.frame.size.height + 12;
}

- (void)showGemPurchaseViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"GemPurchaseViewController"];
    [self setViewControllers:@[viewController] animated:NO];
}

- (void)showSubscriptionViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
    [self setViewControllers:@[viewController] animated:NO];
}

- (void)viewControllerChanged:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 1) {
        [self showGemPurchaseViewController];
    } else {
        [self showSubscriptionViewController];
    }
}

#pragma mark - Helpers
- (CGFloat)getContentInset {
    return self.topHeaderHeight + self.segmentControlHeight;
}

- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat height = MIN(statusBarSize.width, statusBarSize.height);
    return height;
}

- (CGFloat)getContentOffset {
    if ((self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height) <
        self.bgViewOffset) {
        return 0;
    }
    return self.backgroundView.frame.size.height + self.backgroundView.frame.origin.y;
}

- (CGFloat)bgViewOffset {
    return self.statusBarHeight + self.navigationBar.frame.size.height;
}

- (CGFloat)bgHiddenPosition {
    return self.bgViewOffset-self.topHeaderHeight;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setState:(TopHeaderState)state {
    _state = state;
}


@end
