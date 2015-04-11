//
//  HRPGTopHeaderNavigationController.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTopHeaderNavigationController.h"
#import "HRPGUserTopHeader.h"
#import "UIView+Screenshot.h"

@interface HRPGTopHeaderNavigationController ()
@property HRPGUserTopHeader *topHeader;
@property UIImageView *topHeaderImageView;
@property id backgroundView;
@end

@implementation HRPGTopHeaderNavigationController

CGFloat topHeaderHeight = 147;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [self.navigationBar setBackgroundImage:[UIImage new]
               forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    
    self.topHeader = [[HRPGUserTopHeader alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight], self.navigationBar.frame.size.width, topHeaderHeight)];
    self.topHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight], self.navigationBar.frame.size.width, topHeaderHeight)];
    self.topHeaderImageView.contentMode = UIViewContentModeBottom;
    self.topHeaderImageView.clipsToBounds = YES;
    self.isTopHeaderVisible = YES;
    
    if ([UIVisualEffectView class]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [backgroundView setFrame:CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]+topHeaderHeight)];
        
        UIVisualEffectView * seperatorView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [seperatorView setFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight]-1, screenRect.size.width, 1)];
        [backgroundView.contentView addSubview:seperatorView];
        UIView *seperatorLineView = [[UIView alloc] initWithFrame:seperatorView.frame];
        seperatorView.backgroundColor = [UIColor blackColor];
        [seperatorView.contentView addSubview:seperatorLineView];
        
        UIVisualEffectView * bottomBorderView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bottomBorderView setFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight]-1+topHeaderHeight, screenRect.size.width, 1)];
        [backgroundView.contentView addSubview:bottomBorderView];
        UIView *bottomBorderLineView = [[UIView alloc] initWithFrame:bottomBorderView.frame];
        bottomBorderView.backgroundColor = [UIColor blackColor];
        [bottomBorderView.contentView addSubview:bottomBorderLineView];
        
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        
        [backgroundView addSubview:self.topHeader];
        [backgroundView addSubview:self.topHeaderImageView];
        self.backgroundView = backgroundView;
    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+20+topHeaderHeight)];
        backgroundView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.950];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight]-1, screenRect.size.width, 1)];
        seperatorView.backgroundColor = [UIColor colorWithWhite:0.333 alpha:0.720];
        [backgroundView addSubview:seperatorView];
        
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        [backgroundView addSubview:self.topHeader];
        [backgroundView addSubview:self.topHeaderImageView];
        self.backgroundView = backgroundView;
    }
}

- (CGFloat)getContentOffset {
    return topHeaderHeight;
}

- (void)showTopBar {
    if (self.isTopHeaderVisible) {
        return;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.topHeaderImageView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^() {
        if ([UIVisualEffectView class]) {
            UIVisualEffectView *backgroundView = self.backgroundView;
            backgroundView.frame = CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]+topHeaderHeight);
        } else {
            UIView *backgroundView = self.backgroundView;
            backgroundView.frame = CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]+topHeaderHeight);
        }
        self.topHeaderImageView.frame = CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight], self.navigationBar.frame.size.width, topHeaderHeight);
    } completion:^(BOOL finished) {
        self.topHeader.alpha = 1;
        self.topHeaderImageView.alpha = 0;
        self.isTopHeaderVisible = YES;
    }];

}

- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat height = MIN(statusBarSize.width, statusBarSize.height);
    return height;
}

- (void)hideTopBar {
    if (!self.isTopHeaderVisible) {
        return;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.topHeaderImageView.image = [self.topHeader pb_takeScreenshot];
    self.topHeader.alpha = 0;
    self.topHeaderImageView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^() {
        if ([UIVisualEffectView class]) {
            UIVisualEffectView *backgroundView = self.backgroundView;
            backgroundView.frame = CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]);
        } else {
            UIView *backgroundView = self.backgroundView;
            backgroundView.frame = CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]);
        }
        self.topHeaderImageView.frame = CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight], self.navigationBar.frame.size.width, 0);
    } completion:^(BOOL finished) {
        self.topHeaderImageView.alpha = 0;
        self.isTopHeaderVisible = NO;
    }];
}

@end
