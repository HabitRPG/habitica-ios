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

@end

@implementation HRPGTopHeaderNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    self.topHeader = [[HRPGUserTopHeader alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight], self.navigationBar.frame.size.width, topHeaderHeight)];
    self.isTopHeaderVisible = YES;
    
    if ([UIVisualEffectView class]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [backgroundView setFrame:CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]+topHeaderHeight)];
        
        UIVisualEffectView * bottomBorderView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bottomBorderView setFrame:CGRectMake(0, self.navigationBar.frame.size.height+[self statusBarHeight]-1+topHeaderHeight, screenRect.size.width, 1)];
        [backgroundView.contentView addSubview:bottomBorderView];
        UIView *bottomBorderLineView = [[UIView alloc] initWithFrame:bottomBorderView.frame];
        bottomBorderView.backgroundColor = [UIColor blackColor];
        [bottomBorderView.contentView addSubview:bottomBorderLineView];
        
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        
        [backgroundView addSubview:self.topHeader];
        self.backgroundView = backgroundView;
    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+[self statusBarHeight]+topHeaderHeight)];
        backgroundView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.980];
        
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        [backgroundView addSubview:self.topHeader];
        self.backgroundView = backgroundView;
    }
}

- (CGFloat)getContentOffset {
    return topHeaderHeight;
}

- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat height = MIN(statusBarSize.width, statusBarSize.height);
    return height;
}

#pragma mark - Animations
- (void)toggleTopBar
{
    // Hide or show the header bar is decided here
    int multiplier = (self.isTopHeaderVisible) ? -1 : 1;
    
    POPBasicAnimation *hideBackground = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    [hideBackground setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            self.isTopHeaderVisible = !self.isTopHeaderVisible;
        }
    }];
    
    // Dividing the height of the view by 2, because layer position is the center of the view.
    if ([UIVisualEffectView class]) {
        UIVisualEffectView *backgroundView = self.backgroundView;
        hideBackground.toValue = [NSNumber numberWithDouble:multiplier * backgroundView.frame.size.height / 2];
        [backgroundView pop_addAnimation:hideBackground forKey:@"hideTopHeader"];
    } else {
        UIView *backgroundView = self.backgroundView;
        hideBackground.toValue = [NSNumber numberWithDouble:multiplier * backgroundView.frame.size.height / 2];
        [backgroundView pop_addAnimation:hideBackground forKey:@"hideTopHeader"];
    }
}

@end