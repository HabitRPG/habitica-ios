//
//  HRPGPetHatchedOverlayView.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGPetHatchedOverlayView.h"

@interface HRPGPetHatchedOverlayView ()
@property UIView *indicatorView;
@property UILabel *label;
@property CGFloat height;
@property CGFloat width;
@end


@implementation HRPGPetHatchedOverlayView

- (id)init {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    self.height = 140;
    self.width = 160;
    
    CGRect frame = CGRectMake((screenSize.width - self.width) / 2, -self.height, self.width, self.height);
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        self.indicatorView = [[UIView alloc] initWithFrame:frame];
        self.indicatorView.backgroundColor = [UIColor whiteColor];
        [self.indicatorView.layer setCornerRadius:5.0f];
        
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0];
        
        self.petImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, self.width-20, self.height-50)];
        self.petImageView.contentMode = UIViewContentModeCenter;
        [self.indicatorView addSubview:self.petImageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, self.height - 40, self.width-20, 20)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        [self.indicatorView addSubview:self.label];
        
        UITabBarController *mainTabbar = ((UITabBarController *) [[UIApplication sharedApplication] delegate].window.rootViewController);
        [mainTabbar.view addSubview:self];
        [mainTabbar.view addSubview:self.indicatorView];

        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.indicatorView addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (void)display:(void (^)())completitionBlock {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.25];
        self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, (screenSize.height - self.height) / 2, self.width, self.height);
    }                completion:^(BOOL complete) {
        completitionBlock();
    }];
}

- (void)dismiss:(void (^)())completitionBlock {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0];
        self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, screenSize.height, self.width, self.height);
    }                completion:^(BOOL complete) {
        [self.indicatorView removeFromSuperview];
        [self removeFromSuperview];
        completitionBlock();
    }];
}

- (void)setPetHatched:(NSString *)hatchString {
    self.label.text = hatchString;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSInteger height = [hatchString boundingRectWithSize:CGSizeMake(self.width-20, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                         NSFontAttributeName : self.label.font
                                                         }
                                                 context:nil].size.height+5;
    self.height = self.height + height;
    self.label.frame = CGRectMake(10, self.height-height-10, self.width-20, height);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, -self.height, self.width, self.height);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self dismiss:^() {
        
    }];
}
@end
