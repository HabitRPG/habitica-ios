//
//  HRPGActivityIndicatorOverlayView.m
//  Habitica
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGActivityIndicatorOverlayView.h"
#import "HRPGActivityIndicator.h"

@interface HRPGActivityIndicatorOverlayView ()
@property UIView *indicatorView;
@property UIView *backgroundView;
@property UILabel *label;
@property HRPGActivityIndicator *roundProgress;
@end

@implementation HRPGActivityIndicatorOverlayView

static CGFloat width = 150;
CGFloat height = 140;

- (id)initWithString:(NSString *)activityString withColor:(UIColor*)color {
    self.activityString = activityString;
    self.ballColor = color;
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
        self.roundProgress = [[HRPGActivityIndicator alloc] initWithFrame:CGRectMake(30, 30, width - 60, indicatorHeight - 60)];
        [self.roundProgress setLineWidth:2.5];
        
        [self.roundProgress beginAnimating];
        [self.indicatorView addSubview:self.roundProgress];
        
        if (self.activityString) {
            height = height + 50;
            self.label = [[UILabel alloc] initWithFrame:CGRectMake(5, height - 60, width-10, 50)];
            self.label.numberOfLines = 0;
            self.label.text = self.activityString;
            self.label.textAlignment = NSTextAlignmentCenter;
            [self.indicatorView addSubview:self.label];
        }
    }
    return self;
}

- (void)display:(void (^)())completitionBlock {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:self.backgroundView];
    [mainWindow addSubview:self.indicatorView];
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
