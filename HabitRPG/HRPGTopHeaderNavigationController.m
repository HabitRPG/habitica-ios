//
//  HRPGTopHeaderNavigationController.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTopHeaderNavigationController.h"
#import "HRPGUserTopHeader.h"
#import <pop/POP.h>
#import "UIColor+Habitica.h"

@interface HRPGTopHeaderNavigationController ()

@property (nonatomic, strong) HRPGUserTopHeader *topHeader;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *bottomBorderView;
@property (nonatomic, strong) UIView *upperBackgroundView;
@property (nonatomic, readonly) CGFloat topHeaderHeight;

- (CGFloat)statusBarHeight;
- (CGFloat)bgViewOffset;

@property UIScrollView *scrollableView;
@property UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic) CGFloat previousScrollViewYOffset;
@property CGFloat delayDistance;
@property CGFloat maxDelay;
@property HRPGTopHeaderState previousState;
@end

@implementation HRPGTopHeaderNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    
    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"HRPGUserTopHeader" owner:self options:nil];
    self.topHeader = [nibViews objectAtIndex:0];
    self.state = HRPGTopHeaderStateVisible;
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor gray600];
    
    self.bottomBorderView = [[UIView alloc] init];
    [self.bottomBorderView setBackgroundColor:[UIColor gray400]];
    
    self.upperBackgroundView = [[UIView alloc] init];
    [self.upperBackgroundView setBackgroundColor:[UIColor gray600]];
    
    [self.backgroundView addSubview:self.bottomBorderView];
    [self.backgroundView addSubview:self.topHeader];
    [self.view insertSubview:self.upperBackgroundView belowSubview:self.navigationBar];
    [self.view insertSubview:self.backgroundView belowSubview:self.upperBackgroundView];
    
    self.maxDelay = 50;
}


-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect parentFrame = self.view.frame;
    if (self.state == HRPGTopHeaderStateVisible) {
        self.backgroundView.frame = CGRectMake(0, [self bgViewOffset], parentFrame.size.width, self.topHeaderHeight);
    } else {
        self.backgroundView.frame = CGRectMake(0, -self.topHeaderHeight, parentFrame.size.width, self.topHeaderHeight);
    }
    self.upperBackgroundView.frame = CGRectMake(0, 0, parentFrame.size.width, [self bgViewOffset]);
    self.bottomBorderView.frame = CGRectMake(0, self.backgroundView.frame.size.height - 6, parentFrame.size.width, 6);
    self.topHeader.frame = CGRectMake(0, 0, parentFrame.size.width, self.topHeaderHeight-6);
}

- (void)stoppedScrolling:(CGFloat)delta {
    CGRect frame = self.backgroundView.frame;
    if (frame.origin.y < [self bgViewOffset] && frame.origin.y > -frame.size.height) {
        if (self.previousState == HRPGTopHeaderStateHidden) {
            [self showHeader];
        } else {
            [self hideHeader];
        }

    }
}

- (void)showHeader {
    self.state = HRPGTopHeaderStateVisible;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^() {
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = [self bgViewOffset];
        self.backgroundView.frame = frame;
        [self setNavigationBarColors:0];
    } completion:nil];
}

- (void)hideHeader {
    self.state = HRPGTopHeaderStateHidden;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^() {
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = -frame.size.height;
        self.backgroundView.frame = frame;
        [self setNavigationBarColors:1];
    } completion:nil];
}

- (void)startFollowingScrollView:(UIScrollView *)scrollView {
    if (self.scrollableView) {
        [self stopFollowingScrollView];
    }
    
    self.scrollableView = scrollView;
    
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.gestureRecognizer.maximumNumberOfTouches = 1;
    self.gestureRecognizer.delegate = self;
    [self.scrollableView addGestureRecognizer:self.gestureRecognizer];
}

- (void)stopFollowingScrollView {
    [self.scrollableView removeGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer = nil;
    self.scrollableView = nil;
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer {
    
    CGPoint translation = [recognizer translationInView:self.scrollableView.superview];
    CGFloat delta = self.previousScrollViewYOffset - translation.y;
    self.previousScrollViewYOffset = translation.y;
    
    BOOL didStopScrolling = NO;
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        didStopScrolling = YES;
        self.previousScrollViewYOffset = 0;
    }
    
    if ([self shouldScrollWithDelta:delta]) {
        [self scrollWithDelta:delta stoppedScrolling:didStopScrolling];
    }
}

- (BOOL)shouldScrollWithDelta:(CGFloat)delta {
    if (delta < 0) {
            if (self.scrollableView.contentOffset.y + self.scrollableView.frame.size.height > self.scrollableView.contentSize.height) {
                if (self.scrollableView.frame.size.height < self.scrollableView.contentSize.height) {
                    // Only if the content is big enough
                    return false;
                }
            }
    }
    return true;
}

- (void)scrollWithDelta:(CGFloat)delta stoppedScrolling:(BOOL)didStopScrolling {
    CGRect frame = self.backgroundView.frame;
    
    // View scrolling up, hide the header
    if (delta > 0) {
        // No need to scroll if the content fits
        if (self.state != HRPGTopHeaderStateHidden) {
            if (self.scrollableView.frame.size.height >= self.scrollableView.contentSize.height) {
                return;
            }
        }
        
        // Compute the bar position
        if (frame.origin.y - delta < -frame.size.height) {
            delta = frame.origin.y + frame.size.height;
        }
        
        // Detect when the bar is completely collapsed
        if (frame.origin.y == -frame.size.height) {
            self.state = HRPGTopHeaderStateHidden;
            self.delayDistance = self.maxDelay;
        } else {
            self.state = HRPGTopHeaderStateVisible;
        }
    }
    
    if (delta < 0) {
        // Update the delay
        self.delayDistance += delta;
        
        // Skip if the delay is not over yet
        if (self.delayDistance > 0 && self.maxDelay < self.scrollableView.contentOffset.y) {
            return;
        }
        
        // Compute the bar position
        if (frame.origin.y - delta > self.bgViewOffset) {
            delta = frame.origin.y - self.bgViewOffset;
        }
        
        // Detect when the bar is completely expanded
        if (frame.origin.y == self.bgViewOffset) {
            self.state = HRPGTopHeaderStateVisible;
        } else {
            self.state = HRPGTopHeaderStateScrolling;
        }
    }
    
    if (delta != 0) {
        CGFloat alpha = -((frame.origin.y-[self bgViewOffset]) / frame.size.height);
        [self updateSizing:delta];
        [self setNavigationBarColors:alpha];
    }
    if (didStopScrolling) {
        [self stoppedScrolling:delta];
    }
}

- (void)updateSizing:(CGFloat)delta {
    CGRect frame = self.backgroundView.frame;
    frame.origin = CGPointMake(frame.origin.x, frame.origin.y - delta);
    self.backgroundView.frame = frame;
}

- (void)setNavigationBarColors:(CGFloat) alpha {
    self.upperBackgroundView.backgroundColor = [[UIColor gray600] blendWithColor:[UIColor purple300] alpha:alpha];
    self.navigationBar.tintColor = [[UIColor purple400] blendWithColor:[UIColor gray600] alpha:alpha];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [[UIColor blackColor] blendWithColor:[UIColor whiteColor] alpha:alpha]};
    if (self.navigationBar.barStyle == UIBarStyleDefault && alpha > 0.5) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        [self setNeedsStatusBarAppearanceUpdate];
    } else if (self.navigationBar.barStyle == UIBarStyleBlack && alpha < 0.5) {
        self.navigationBar.barStyle = UIBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.navigationBar.barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (CGFloat)topHeaderHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 200;
    } else {
        return 168;
    }
}

#pragma mark - Helpers
- (CGFloat)getContentInset
{
    return self.topHeaderHeight;
}

- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat height = MIN(statusBarSize.width, statusBarSize.height);
    return height;
}

- (CGFloat)getContentOffset {
    return self.backgroundView.frame.size.height;
}

- (CGFloat)bgViewOffset
{
    return self.statusBarHeight + self.navigationBar.frame.size.height;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setState:(HRPGTopHeaderState)state {
    if (state != _state) {
        self.previousState = _state;
    }
    _state = state;
}

@end