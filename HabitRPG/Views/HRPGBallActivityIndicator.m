//
//  HRPGBallActivityIndicator.m
//  RabbitRPG
//
//  Created by Phillip on 08/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBallActivityIndicator.h"
#import "HRPGBall.h"

@interface HRPGBallActivityIndicator ()

@property(nonatomic) NSMutableArray *balls;
@property CGFloat ballWidth;
@property CGFloat ballHeight;
@end

@implementation HRPGBallActivityIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.stepDuration = 0.8f;
        self.stepDelay = 0.2f;
        self.springDampening = 0.6f;
        self.springVelocity = 0.9f;
        self.balls = [NSMutableArray arrayWithCapacity:4];
        self.ballWidth = self.frame.size.width / 5;
        self.ballHeight = self.frame.size.height / 5;
        self.ballColor = [UIColor colorWithRed:0.409 green:0.743 blue:0.037 alpha:0.8];
        CGRect ballRect = CGRectMake(self.frame.size.width / 2 - self.ballWidth / 2,
                                     self.frame.size.height / 2 - self.ballHeight / 2,
                                     self.ballWidth, self.ballHeight);
        for (int x = 0; x < 4; x++) {
            HRPGBall *ball = [[HRPGBall alloc] initWithFrame:ballRect];
            ball.ballColor = self.ballColor;
            [self.balls addObject:ball];
            [self addSubview:ball];
        }
    }
    return self;
}

- (void)setBallsPosition {
    for (int x = 0; x < 4; x++) {
        CGRect ballRect;
        if (x == 0) {
            ballRect = CGRectMake(self.frame.size.width / 2 - self.ballWidth / 2, 0, self.ballWidth,
                                  self.ballHeight);
        } else if (x == 1) {
            ballRect = CGRectMake(self.frame.size.width - self.ballWidth,
                                  self.frame.size.height / 2 - self.ballHeight / 2, self.ballWidth,
                                  self.ballHeight);
        } else if (x == 2) {
            ballRect = CGRectMake(self.frame.size.width / 2 - self.ballWidth / 2,
                                  self.frame.size.height - self.ballHeight, self.ballWidth,
                                  self.ballHeight);
        } else if (x == 3) {
            ballRect = CGRectMake(0, self.frame.size.height / 2 - self.ballHeight / 2,
                                  self.ballWidth, self.ballHeight);
        }
        HRPGBall *ball = self.balls[x];
        ball.frame = ballRect;
    }
}

- (void)setBallColor:(UIColor *)ballColor {
    _ballColor = ballColor;
    for (HRPGBall *ball in self.balls) {
        ball.ballColor = self.ballColor;
    }
}
- (void)animate {
    [UIView animateWithDuration:self.stepDuration
        delay:self.stepDelay
        usingSpringWithDamping:self.springDampening
        initialSpringVelocity:self.springVelocity
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^() {
            HRPGBall *ball1 = self.balls[0];
            ball1.frame = CGRectMake((self.frame.size.width / 5) * 4 - self.ballWidth / 2,
                                     (self.frame.size.width / 5) * 4 - self.ballWidth / 2,
                                     self.ballWidth, self.ballHeight);
            HRPGBall *ball2 = self.balls[1];
            ball2.frame = CGRectMake((self.frame.size.width / 5) - self.ballWidth / 2,
                                     (self.frame.size.width / 5) * 4 - self.ballWidth / 2,
                                     self.ballWidth, self.ballHeight);
            HRPGBall *ball3 = self.balls[2];
            ball3.frame = CGRectMake((self.frame.size.width / 5) - self.ballWidth / 2,
                                     (self.frame.size.width / 5) - self.ballWidth / 2,
                                     self.ballWidth, self.ballHeight);
            HRPGBall *ball4 = self.balls[3];
            ball4.frame = CGRectMake((self.frame.size.width / 5) * 4 - self.ballWidth / 2,
                                     (self.frame.size.width / 5) - self.ballWidth / 2,
                                     self.ballWidth, self.ballHeight);
        }
        completion:^(BOOL complete) {
            if (complete) {
                [UIView animateWithDuration:self.stepDuration
                    delay:self.stepDelay
                    usingSpringWithDamping:self.springDampening
                    initialSpringVelocity:self.springVelocity
                    options:UIViewAnimationOptionCurveEaseInOut
                    animations:^() {
                        HRPGBall *ball1 = self.balls[0];
                        ball1.frame =
                            CGRectMake(0, self.frame.size.height / 2 - self.ballHeight / 2,
                                       self.ballWidth, self.ballHeight);
                        HRPGBall *ball2 = self.balls[1];
                        ball2.frame = CGRectMake(self.frame.size.width / 2 - self.ballWidth / 2, 0,
                                                 self.ballWidth, self.ballHeight);
                        HRPGBall *ball3 = self.balls[2];
                        ball3.frame = CGRectMake(self.frame.size.width - self.ballWidth,
                                                 self.frame.size.height / 2 - self.ballHeight / 2,
                                                 self.ballWidth, self.ballHeight);
                        HRPGBall *ball4 = self.balls[3];
                        ball4.frame = CGRectMake(self.frame.size.width / 2 - self.ballWidth / 2,
                                                 self.frame.size.height - self.ballHeight,
                                                 self.ballWidth, self.ballHeight);
                    }
                    completion:^(BOOL complete) {
                        if (complete) {
                            [self setBallsPosition];
                            [self animate];
                        }
                    }];
            }
        }];
}

- (void)beginAnimating {
    [self animate];
}

- (void)endAnimating {
    [self.layer removeAllAnimations];
}

@end
