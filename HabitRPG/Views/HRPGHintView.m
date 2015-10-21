//
//  HRPGHintView.m
//  Habitica
//
//  Created by Phillip Thelen on 21/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGHintView.h"
#import "UIColor+Habitica.h"

@interface HRPGHintView ()

@property UIView *pulseView;

@property CGFloat pulseSize;
@property CGFloat duration;

@end

@implementation HRPGHintView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.layer.borderColor = [UIColor purple300].CGColor;
        self.layer.borderWidth = 2;
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        self.pulseView = [[UIView alloc] init];
        self.pulseView.layer.borderColor = [UIColor purple300].CGColor;
        self.pulseView.layer.borderWidth = 1;
        [self addSubview:self.pulseView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layer.cornerRadius = frame.size.height/2;
    self.pulseView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.pulseView.layer.cornerRadius = frame.size.height/2;
}

-(void)pulseToSize: (float) value withDuration:(float) duration {
    [self.pulseView.layer removeAllAnimations];
    self.pulseSize = value;
    self.duration = duration;
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = duration;
    pulseAnimation.toValue = [NSNumber numberWithFloat:value];;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = NO;
    pulseAnimation.repeatCount = FLT_MAX;
    
    [self.pulseView.layer addAnimation:pulseAnimation forKey:nil];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = duration;
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    opacityAnimation.autoreverses = NO;
    opacityAnimation.repeatCount = FLT_MAX;
    
    [self.pulseView.layer addAnimation:opacityAnimation forKey:nil];
}

- (void)continueAnimating {
    [self pulseToSize:self.pulseSize withDuration:self.duration];
}

@end
