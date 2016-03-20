//
//  HRPGBallActivityIndicator.h
//  RabbitRPG
//
//  Created by Phillip on 08/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGBallActivityIndicator : UIView

@property(nonatomic) UIColor *ballColor;
@property CGFloat stepDuration;
@property CGFloat springDampening;
@property CGFloat springVelocity;
@property CGFloat stepDelay;

- (void)beginAnimating;
- (void)endAnimating;
- (void)animate;

@end
