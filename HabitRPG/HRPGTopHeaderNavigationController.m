//
//  HRPGTopHeaderNavigationController.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTopHeaderNavigationController.h"
#import "HRPGUserTopHeader.h"

@interface HRPGTopHeaderNavigationController ()
@property HRPGUserTopHeader *topHeader;
@end

@implementation HRPGTopHeaderNavigationController

CGFloat topHeaderHeight = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [self.navigationBar setBackgroundImage:[UIImage new]
               forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    
    self.topHeader = [[HRPGUserTopHeader alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+20, self.navigationBar.frame.size.width, topHeaderHeight)];
    
    if ([UIVisualEffectView class]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [backgroundView setFrame:CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+20+topHeaderHeight)];
        
        UIVisualEffectView * seperatorView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [seperatorView setFrame:CGRectMake(0, self.navigationBar.frame.size.height+20, screenRect.size.width, 1)];
        [backgroundView.contentView addSubview:seperatorView];
        UIView *seperatorLineView = [[UIView alloc] initWithFrame:seperatorView.frame];
        seperatorView.backgroundColor = [UIColor blackColor];
        [seperatorView.contentView addSubview:seperatorLineView];
        
        UIVisualEffectView * bottomBorderView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bottomBorderView setFrame:CGRectMake(0, self.navigationBar.frame.size.height+19+topHeaderHeight, screenRect.size.width, 1)];
        [backgroundView.contentView addSubview:bottomBorderView];
        UIView *bottomBorderLineView = [[UIView alloc] initWithFrame:bottomBorderView.frame];
        bottomBorderView.backgroundColor = [UIColor blackColor];
        [bottomBorderView.contentView addSubview:bottomBorderLineView];
        
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        
        [backgroundView addSubview:self.topHeader];
    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, self.navigationBar.frame.size.height+20+topHeaderHeight)];
        backgroundView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.950];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+20, screenRect.size.width, 1)];
        seperatorView.backgroundColor = [UIColor colorWithWhite:0.333 alpha:0.720];
        [backgroundView addSubview:seperatorView];
        
        [self.view insertSubview:backgroundView belowSubview:self.navigationBar];
        [backgroundView addSubview:self.topHeader];
    }
}

- (CGFloat)getContentOffset {
    return topHeaderHeight;
}

@end
