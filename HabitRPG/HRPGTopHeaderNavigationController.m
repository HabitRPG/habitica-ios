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

static const CGFloat topHeaderHeight = 147;

@interface HRPGTopHeaderNavigationController ()

@property (nonatomic, strong) HRPGUserTopHeader *topHeader;
@property (nonatomic, strong) id backgroundView;
@property BOOL isTopHeaderVisible;

- (CGFloat)statusBarHeight;
- (CGFloat)bgViewOffset;

@end

@implementation HRPGTopHeaderNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    self.navigationBar.translucent = YES;
    
    self.topHeader = [[HRPGUserTopHeader alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, topHeaderHeight)];
    self.isTopHeaderVisible = YES;
    
    if ([UIVisualEffectView class]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [backgroundView setFrame:CGRectMake(0, [self bgViewOffset], screenRect.size.width, topHeaderHeight)];
        
        UIVisualEffectView *bottomBorderView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bottomBorderView setFrame:CGRectMake(0, topHeaderHeight - 1, screenRect.size.width, 1)];
        [bottomBorderView setBackgroundColor:[UIColor blackColor]];
        
        [backgroundView addSubview:bottomBorderView];
        [backgroundView addSubview:self.topHeader];
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        self.backgroundView = backgroundView;
    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [self bgViewOffset], screenRect.size.width, topHeaderHeight)];
        backgroundView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.980];
        
        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeaderHeight - 1, screenRect.size.width, 1)];
        [bottomBorderView setBackgroundColor:[UIColor lightGrayColor]];
        
        [backgroundView addSubview:bottomBorderView];
        [backgroundView addSubview:self.topHeader];
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        self.backgroundView = backgroundView;
    }
}

#pragma mark - Helpers
- (CGFloat)getContentOffset
{
    return topHeaderHeight;
}

- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat height = MIN(statusBarSize.width, statusBarSize.height);
    return height;
}

- (CGFloat)bgViewOffset
{
    return [self statusBarHeight] + self.navigationBar.frame.size.height;
}

#pragma mark - Animations
- (void)toggleTopBar
{
    // Hide or show the header bar is decided here
    int multiplier = (self.isTopHeaderVisible) ? -1 : 1;
    self.isTopHeaderVisible = !self.isTopHeaderVisible;
    
    POPBasicAnimation *hideBackground = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    UIView *backgroundView = self.backgroundView;
    // Dividing the height of the view by 2, because layer position is the center of the view.
    hideBackground.toValue = [NSNumber numberWithDouble:[self bgViewOffset] + multiplier * (backgroundView.frame.size.height / 2)];
    [backgroundView pop_addAnimation:hideBackground forKey:@"hideTopHeader"];
}

@end