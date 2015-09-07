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

static const CGFloat topHeaderHeight = 168;

@interface HRPGTopHeaderNavigationController ()

@property (nonatomic, strong) HRPGUserTopHeader *topHeader;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *bottomBorderView;
@property (nonatomic, strong) UIView *upperBackgroundView;

- (CGFloat)statusBarHeight;
- (CGFloat)bgViewOffset;

@end

@implementation HRPGTopHeaderNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [self.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.topHeader = [[HRPGUserTopHeader alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, topHeaderHeight-6)];
    self.isTopHeaderVisible = YES;
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [self bgViewOffset], screenRect.size.width, topHeaderHeight)];
    self.backgroundView.backgroundColor = [UIColor gray600];
    
    self.bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height - 6, screenRect.size.width, 6)];
    [self.bottomBorderView setBackgroundColor:[UIColor gray300]];
    
    self.upperBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, [self bgViewOffset])];
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
        self.backgroundView.frame = CGRectMake(0, [self bgViewOffset], parentFrame.size.width, topHeaderHeight);
    } else {
        self.backgroundView.frame = CGRectMake(0, -topHeaderHeight, parentFrame.size.width, topHeaderHeight);
    }
    self.upperBackgroundView.frame = CGRectMake(0, 0, parentFrame.size.width, [self bgViewOffset]);
    self.bottomBorderView.frame = CGRectMake(0, self.backgroundView.frame.size.height - 6, parentFrame.size.width, 6);
    self.topHeader.frame = CGRectMake(0, 0, parentFrame.size.width, topHeaderHeight-6);
}

#pragma mark - Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.backgroundView.frame;
    CGFloat size = frame.size.height;
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        self.isTopHeaderVisible = YES;
        frame.origin.y = [self bgViewOffset];
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        self.isTopHeaderVisible = NO;
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN([self bgViewOffset], MAX(-size, frame.origin.y - scrollDiff));
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
    self.upperBackgroundView.backgroundColor = [[UIColor gray600] blendWithColor:[UIColor purple200] alpha:alpha];
    self.navigationBar.tintColor = [[UIColor purple400] blendWithColor:[UIColor gray600] alpha:alpha];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [[UIColor blackColor] blendWithColor:[UIColor whiteColor] alpha:alpha]};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}


#pragma mark - Helpers
- (CGFloat)getContentInset
{
    return topHeaderHeight;
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