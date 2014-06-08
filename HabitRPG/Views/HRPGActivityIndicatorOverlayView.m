//
//  HRPGActivityIndicatorOverlayView.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGActivityIndicatorOverlayView.h"
#import "HRPGBallActivityIndicator.h"

@interface HRPGActivityIndicatorOverlayView ()
@property UIView *indicatorView;
@property UIView *backgroundView;
@property UILabel *label;
@end


@implementation HRPGActivityIndicatorOverlayView

static CGFloat width = 140;
CGFloat height = 140;

- (id)initWithString:(NSString *)activityString {
    self.activityString = activityString;
    return [self init];
}


- (id)init {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGRect frame = CGRectMake((screenSize.width - width) / 2, -height, width, height);
    self = [super init];
    if (self) {
        height = 140;
        CGFloat indicatorHeight = height;

        self.indicatorView = [[UIView alloc] initWithFrame:frame];
        self.indicatorView.backgroundColor = [UIColor whiteColor];
        [self.indicatorView.layer setCornerRadius:5.0f];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0];
        HRPGBallActivityIndicator *roundProgress = [[HRPGBallActivityIndicator alloc] initWithFrame:CGRectMake(30, 30, width - 60, indicatorHeight - 60)];
        roundProgress.ballColor = [UIColor colorWithRed:0.824 green:0.113 blue:0.104 alpha:0.8];
        [roundProgress beginAnimating];
        [self.indicatorView addSubview:roundProgress];
        
        if (self.activityString) {
            height = height + 40;
            self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 40, width, 20)];
            self.label.text = self.activityString;
            self.label.textAlignment = NSTextAlignmentCenter;
            [self.indicatorView addSubview:self.label];
        }
        
        UITabBarController *mainTabbar = ((UITabBarController *) [[UIApplication sharedApplication] delegate].window.rootViewController);
        [mainTabbar.view addSubview:self.backgroundView];
        [mainTabbar.view addSubview:self.indicatorView];
    }
    return self;
}

- (void)display:(void (^)())completitionBlock {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.25];
        self.indicatorView.frame = CGRectMake((screenSize.width - width) / 2, (screenSize.height - height) / 2, width, height);
    }                completion:^(BOOL complete) {
        completitionBlock();
    }];
}

- (void)dismiss:(void (^)())completitionBlock {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0];
        self.indicatorView.frame = CGRectMake((screenSize.width - width) / 2, screenSize.height, width, height);
    }                completion:^(BOOL complete) {
        [self.backgroundView removeFromSuperview];
        [self.indicatorView removeFromSuperview];
        completitionBlock();
    }];
}

@end
