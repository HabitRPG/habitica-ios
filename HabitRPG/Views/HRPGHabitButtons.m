//
//  HRPGHabitButton.m
//  Habitica
//
//  Created by viirus on 22.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGHabitButtons.h"
#import "UIColor+LighterDarker.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGHabitButtons ()

@property(nonatomic) UIImageView *label;
@property(nonatomic) UIView *roundedView;
@property CGFloat buttonSize;

@property(nonatomic, copy) void (^action)();
@end

@implementation HRPGHabitButtons

#pragma mark - Configuration

- (void)configureForTask:(Task *)task isNegative:(BOOL)isNegative {
    self.buttonSize = 32;
    [self cleanUp];

    BOOL isActive = isNegative ? task.down : task.up;
    
    self.label = [[UIImageView alloc] init];
    [self addSubview:self.label];
    self.roundedView = [[UIView alloc] init];
    self.roundedView.layer.cornerRadius = self.buttonSize/2;
    [self insertSubview:self.roundedView belowSubview:self.label];

    if (isActive) {
        if (isNegative) {
            self.label.image = [UIImage imageNamed:@"minus"];
        } else {
            self.label.image = [UIImage imageNamed:@"plus"];
        }
        self.label.contentMode = UIViewContentModeCenter;

        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleSingleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        self.label.userInteractionEnabled = YES;
        [self.label addGestureRecognizer:tapRecognizer];
        self.backgroundColor = [task lightTaskColor];
        
        NSInteger taskValue = task.value;
        if (taskValue >= -10 && taskValue < -1) {
            self.roundedView.backgroundColor = [UIColor orange10];
        } else if (taskValue >= -1 && taskValue < 1) {
            self.roundedView.backgroundColor = [UIColor yellow10];
        } else {
            self.roundedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        }
    } else {
        if (isNegative) {
             UIImage *image = [UIImage imageNamed:@"minus_gray"];
            self.label.image = image;
        } else {
            self.label.image = [UIImage imageNamed:@"plus_gray"];
        }
        self.label.contentMode = UIViewContentModeCenter;
        self.backgroundColor = [UIColor gray700];
        self.roundedView.layer.borderWidth = 1;
        self.roundedView.layer.borderColor = [UIColor gray600].CGColor;
    }
}

- (void)cleanUp {
    self.backgroundColor = [UIColor clearColor];
    if (self.label) {
        [self.label removeFromSuperview];
        self.label = nil;
    }
    if (self.roundedView) {
        [self.roundedView removeFromSuperview];
        self.roundedView = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    int verticalCenter = self.frame.size.height / 2;
    int horizontalCenter = self.frame.size.width / 2;
    self.roundedView.frame = CGRectMake(horizontalCenter - self.buttonSize/2, verticalCenter - self.buttonSize/2, self.buttonSize, self.buttonSize);
    
    if (self.label) {
        self.label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

- (void)action:(void (^)())actionBlock {
    self.action = actionBlock;
}

#pragma mark - Gesture recognizers

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2
        animations:^() {
            self.label.backgroundColor = [self.backgroundColor lighterColor];
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2
                             animations:^() {
                                 self.label.backgroundColor = nil;
                             }];
        }];
    if (self.action) {
        self.action();
    }
}

@end
