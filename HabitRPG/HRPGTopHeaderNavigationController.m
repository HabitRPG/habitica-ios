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

UIVisualEffectView *backgroundView;
CGFloat topHeaderHeight = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [self.navigationBar setBackgroundImage:[UIImage new]
               forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
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
    
    self.topHeader = [[HRPGUserTopHeader alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height+20, self.navigationBar.frame.size.width, topHeaderHeight)];
    [backgroundView addSubview:self.topHeader];
}

- (CGFloat)getContentOffset {
    return topHeaderHeight;
}

@end
