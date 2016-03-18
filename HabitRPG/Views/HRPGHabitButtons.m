//
//  HRPGHabitButton.m
//  Habitica
//
//  Created by viirus on 22.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitButtons.h"
#import <pop/POP.h>
#import "Task.h"
#import "UIColor+LighterDarker.h"

@interface HRPGHabitButtons ()

@property(nonatomic) UIImageView *upLabel;
@property(nonatomic) UIImageView *downLabel;
@property(nonatomic) UIView *roundedView;

@property(nonatomic, copy) void (^upAction)();
@property(nonatomic, copy) void (^downAction)();
@end

@implementation HRPGHabitButtons

#pragma mark - Configuration

- (void)configureForTask:(Task *)task {
    [self cleanUp];

    if ([task.up boolValue]) {
        self.upLabel = [[UIImageView alloc] init];
        self.upLabel.image = [UIImage imageNamed:@"plus"];
        self.upLabel.contentMode = UIViewContentModeCenter;
        [self addSubview:self.upLabel];

        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleUpSingleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        self.upLabel.userInteractionEnabled = YES;
        [self.upLabel addGestureRecognizer:tapRecognizer];
    }

    if ([task.down boolValue]) {
        self.downLabel = [[UIImageView alloc] init];
        self.downLabel.image = [UIImage imageNamed:@"minus"];
        self.downLabel.contentMode = UIViewContentModeCenter;
        [self addSubview:self.downLabel];

        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleDownSingleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        self.downLabel.userInteractionEnabled = YES;
        [self.downLabel addGestureRecognizer:tapRecognizer];
    }

    if ([task.up boolValue] && [task.down boolValue]) {
        self.upLabel.backgroundColor = [task lightTaskColor];
        self.downLabel.backgroundColor = [task taskColor];
    } else {
        self.backgroundColor = [task lightTaskColor];
        self.roundedView = [[UIView alloc] init];
        self.roundedView.backgroundColor = [task taskColor];
        self.roundedView.layer.cornerRadius = 20;
        if (self.upLabel) {
            [self insertSubview:self.roundedView belowSubview:self.upLabel];
        } else {
            [self insertSubview:self.roundedView belowSubview:self.downLabel];
        }
    }
}

- (void)cleanUp {
    self.backgroundColor = [UIColor clearColor];
    if (self.upLabel) {
        [self.upLabel removeFromSuperview];
        self.upLabel = nil;
    }
    if (self.downLabel) {
        [self.downLabel removeFromSuperview];
        self.downLabel = nil;
    }
    if (self.roundedView) {
        [self.roundedView removeFromSuperview];
        self.roundedView = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.upLabel && self.downLabel) {
        self.upLabel.frame =
            CGRectMake(0, 0, self.frame.size.width, (int)self.frame.size.height / 2);
        self.downLabel.frame = CGRectMake(0, (int)self.frame.size.height / 2, self.frame.size.width,
                                          self.frame.size.height - (int)self.frame.size.height / 2);
    } else {
        int verticalCenter = self.frame.size.height / 2;
        int horizontalCenter = self.frame.size.width / 2;
        self.roundedView.frame = CGRectMake(horizontalCenter - 20, verticalCenter - 20, 40, 40);

        if (self.upLabel) {
            self.upLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
        if (self.downLabel) {
            self.downLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
    }
}

- (void)onUpAction:(void (^)())actionBlock {
    self.upAction = actionBlock;
}

- (void)onDownAction:(void (^)())actionBlock {
    self.downAction = actionBlock;
}

#pragma mark - Gesture recognizers

- (void)handleUpSingleTap:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2
        animations:^() {
            self.upLabel.backgroundColor = [self.upLabel.backgroundColor darkerColor];
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2
                             animations:^() {
                                 self.upLabel.backgroundColor =
                                     [self.upLabel.backgroundColor lighterColor];
                             }];
        }];
    if (self.upAction) {
        self.upAction();
    }
}

- (void)handleDownSingleTap:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2
        animations:^() {
            self.downLabel.backgroundColor = [self.downLabel.backgroundColor darkerColor];
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2
                             animations:^() {
                                 self.downLabel.backgroundColor =
                                     [self.downLabel.backgroundColor lighterColor];
                             }];
        }];
    if (self.downAction) {
        self.downAction();
    }
}

@end
