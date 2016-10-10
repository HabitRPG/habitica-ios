//
//  HRPGGemHeaderNavigationController.m
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGGemHeaderNavigationController.h"
#import "UIColor+Habitica.h"

@interface HRPGGemHeaderNavigationController ()
@property(nonatomic, strong) UIView *headerView;
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIView *upperBackgroundView;
@property(nonatomic, readonly) CGFloat topHeaderHeight;

- (CGFloat)statusBarHeight;
- (CGFloat)bgViewOffset;

@property UIScrollView *scrollableView;
@property UIPanGestureRecognizer *gestureRecognizer;
@property CGFloat headerYPosition;
@end

@implementation HRPGGemHeaderNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIImageView *headerImageView = [[UIImageView alloc] init];
    headerImageView.image = [UIImage imageNamed:@"support_art"];
    headerImageView.contentMode = UIViewContentModeCenter;
    self.headerView = headerImageView;
    self.state = HRPGTopHeaderStateVisible;
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    
    self.upperBackgroundView = [[UIView alloc] init];
    [self.upperBackgroundView setBackgroundColor:[UIColor whiteColor]];
    
    [self.backgroundView addSubview:self.headerView];
    [self.view insertSubview:self.upperBackgroundView belowSubview:self.navigationBar];
    [self.view insertSubview:self.backgroundView belowSubview:self.upperBackgroundView];
    
    self.headerYPosition = [self bgViewOffset];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect parentFrame = self.view.frame;
    self.backgroundView.frame =
    CGRectMake(0, self.headerYPosition, parentFrame.size.width, self.topHeaderHeight);
    self.upperBackgroundView.frame = CGRectMake(0, 0, parentFrame.size.width, [self bgViewOffset]);
    self.headerView.frame = CGRectMake(0, 0, parentFrame.size.width, self.topHeaderHeight);
}

- (void)showHeader {
    self.state = HRPGTopHeaderStateVisible;
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = [self bgViewOffset];
    self.headerYPosition = frame.origin.y;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         self.backgroundView.frame = frame;
                         [self setNavigationBarColors:0];
                     }
                     completion:^(BOOL completed){
                     }];
}

- (void)hideHeader {
    self.state = HRPGTopHeaderStateHidden;
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = -frame.size.height;
    self.headerYPosition = frame.origin.y;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         self.backgroundView.frame = frame;
                         [self setNavigationBarColors:1];
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
    }
    if ((newYPos + frame.size.height) > self.bgViewOffset) {
        [self setState:HRPGTopHeaderStateVisible];
    } else {
        if (self.state == HRPGTopHeaderStateHidden) {
            return;
        }
        [self setState:HRPGTopHeaderStateHidden];
    }
    frame.origin = CGPointMake(frame.origin.x, newYPos);
    self.headerYPosition = frame.origin.y;
    self.backgroundView.frame = frame;
    CGFloat alpha = -((frame.origin.y - [self bgViewOffset]) / frame.size.height);
    [self setNavigationBarColors:alpha];
}

- (void)setNavigationBarColors:(CGFloat)alpha {
    self.upperBackgroundView.backgroundColor =
    [[UIColor gray600] blendWithColor:[UIColor purple300] alpha:alpha];
    self.navigationBar.tintColor =
    [[UIColor purple400] blendWithColor:[UIColor whiteColor] alpha:alpha];
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName :
                                                   [[UIColor blackColor] blendWithColor:[UIColor whiteColor] alpha:alpha]
                                               };
    if (self.navigationBar.barStyle == UIBarStyleDefault && alpha > 0.5) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        [self setNeedsStatusBarAppearanceUpdate];
    } else if (self.navigationBar.barStyle == UIBarStyleBlack && alpha < 0.5) {
        self.navigationBar.barStyle = UIBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.navigationBar.barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

- (CGFloat)topHeaderHeight {
        return 100;
}

#pragma mark - Helpers
- (CGFloat)getContentInset {
    return self.topHeaderHeight;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setState:(HRPGTopHeaderState)state {
    _state = state;
}


@end
