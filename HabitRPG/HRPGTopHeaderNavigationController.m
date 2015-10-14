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
    self.isTopHeaderVisible = YES;
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
}


-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect parentFrame = self.view.frame;
    if (self.isTopHeaderVisible) {
        self.backgroundView.frame = CGRectMake(0, [self bgViewOffset], parentFrame.size.width, self.topHeaderHeight);
    } else {
        self.backgroundView.frame = CGRectMake(0, -self.topHeaderHeight, parentFrame.size.width, self.topHeaderHeight);
    }
    self.upperBackgroundView.frame = CGRectMake(0, 0, parentFrame.size.width, [self bgViewOffset]);
    self.bottomBorderView.frame = CGRectMake(0, self.backgroundView.frame.size.height - 6, parentFrame.size.width, 6);
    self.topHeader.frame = CGRectMake(0, 0, parentFrame.size.width, self.topHeaderHeight-6);
}

#pragma mark - Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.backgroundView.frame;
    CGFloat size = frame.size.height;
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        self.isTopHeaderVisible = YES;
        frame.origin.y = [self bgViewOffset];
    } else {
        frame.origin.y = MIN([self bgViewOffset], MAX(-size, frame.origin.y - scrollDiff));
    }
    
    if (frame.origin.y < -size) {
        frame.origin.y = -size;
    }
    
    CGFloat alpha = -((frame.origin.y-[self bgViewOffset]) / frame.size.height);
    [self.backgroundView setFrame:frame];
    [self setNavigationBarColors:alpha];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling {
    CGRect frame = self.backgroundView.frame;
    if (frame.origin.y < [self bgViewOffset] && frame.origin.y > -frame.size.height) {
        if (frame.origin.y < [self bgViewOffset]-(([self bgViewOffset]+frame.size.height)/2)) {
            self.isTopHeaderVisible = NO;
            [UIView animateWithDuration:0.3 animations:^() {
                CGRect frame = self.backgroundView.frame;
                frame.origin.y = -frame.size.height;
                self.backgroundView.frame = frame;
                [self setNavigationBarColors:1];
            }];
        } else {
            self.isTopHeaderVisible = YES;
            [UIView animateWithDuration:0.3 animations:^() {
                CGRect frame = self.backgroundView.frame;
                frame.origin.y = [self bgViewOffset];
                self.backgroundView.frame = frame;
                [self setNavigationBarColors:0];
            }];
        }

    }
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
    return 20 + self.navigationBar.frame.size.height;
}

@end