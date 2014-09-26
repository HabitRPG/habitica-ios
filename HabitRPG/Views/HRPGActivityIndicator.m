//
//  HRPGAcitivityIndicator.m
//  RabbitRPG
//
//  Created by viirus on 15/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGActivityIndicator.h"

@interface HRPGActivityIndicator ()
@property CAShapeLayer *outerRing1;
@property CAShapeLayer *outerRing2;
@property CAShapeLayer *innerRing1;
@property CAShapeLayer *innerRing2;

@end

@implementation HRPGActivityIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat radius = MIN(self.frame.size.width,self.frame.size.height)/2;
        CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, radius*2, radius*2);
        CGFloat outerInset  = 2;
        CGFloat innerInset  = (radius/2) + 4;
        CGFloat lineWidth = 2;
        self.outerRing1 = [CAShapeLayer layer];
        self.outerRing1.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, outerInset, outerInset)
                                               cornerRadius:radius-outerInset].CGPath;
        self.outerRing1.bounds = CGPathGetBoundingBox(self.outerRing1.path);
        self.outerRing1.fillColor   = [UIColor clearColor].CGColor;
        self.outerRing1.strokeColor = [UIColor blackColor].CGColor;
        self.outerRing1.lineWidth   = lineWidth;
        self.outerRing1.strokeStart = 0.0f;
        self.outerRing1.strokeEnd = self.outerRing1.strokeStart;
        [self.outerRing1 setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];

        self.outerRing2 = [CAShapeLayer layer];
        self.outerRing2.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, outerInset, outerInset) cornerRadius:radius-outerInset].CGPath;
        self.outerRing2.bounds = CGPathGetBoundingBox(self.outerRing2.path);
        self.outerRing2.fillColor   = [UIColor clearColor].CGColor;
        self.outerRing2.strokeColor = [UIColor blackColor].CGColor;
        self.outerRing2.lineWidth   = lineWidth;
        self.outerRing2.strokeStart = 0.5f;
        self.outerRing2.strokeEnd = self.outerRing2.strokeStart;
        [self.outerRing2 setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];

        self.innerRing1 = [CAShapeLayer layer];
        self.innerRing1.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, innerInset, innerInset) cornerRadius:radius-outerInset].CGPath;
        self.innerRing1.bounds = CGPathGetBoundingBox(self.innerRing1.path);
        self.innerRing1.fillColor   = [UIColor clearColor].CGColor;
        self.innerRing1.strokeColor = [UIColor blackColor].CGColor;
        self.innerRing1.lineWidth   = (radius-innerInset)*2;
        self.innerRing1.strokeStart = 0.25f;
        self.innerRing1.strokeEnd = self.innerRing1.strokeStart;
        [self.innerRing1 setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        self.innerRing2 = [CAShapeLayer layer];
        self.innerRing2.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, innerInset, innerInset) cornerRadius:radius-outerInset].CGPath;
        self.innerRing2.bounds = CGPathGetBoundingBox(self.innerRing2.path);
        self.innerRing2.fillColor   = [UIColor clearColor].CGColor;
        self.innerRing2.strokeColor = [UIColor blackColor].CGColor;
        self.innerRing2.lineWidth   = (radius-innerInset)*2;
        self.innerRing2.strokeStart = 0.75f;
        self.innerRing2.strokeEnd = self.innerRing2.strokeStart;
        [self.innerRing2 setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        [self.layer addSublayer:self.outerRing1];
        [self.layer addSublayer:self.outerRing2];
        [self.layer addSublayer:self.innerRing1];
        [self.layer addSublayer:self.innerRing2];
    }
    
    return self;
}

- (void) animate {
    CABasicAnimation *outerRingRotate=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    outerRingRotate.fromValue=[NSNumber numberWithDouble:0.0f];
    outerRingRotate.toValue=[NSNumber numberWithDouble:2*M_PI];
    outerRingRotate.duration = 0.8f;
    outerRingRotate.repeatCount = HUGE_VALF;
    outerRingRotate.fillMode = kCAFillModeBoth;
    [self.outerRing1 addAnimation:outerRingRotate forKey:@"rotateOuterRing"];
    [self.outerRing2 addAnimation:outerRingRotate forKey:@"rotateOuterRing"];
    
    CABasicAnimation *innerRingRotate=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    innerRingRotate.fromValue=[NSNumber numberWithDouble:2*M_PI];
    innerRingRotate.toValue=[NSNumber numberWithDouble:0.0f];
    innerRingRotate.duration = 1.4f;
    innerRingRotate.repeatCount = HUGE_VALF;
    innerRingRotate.fillMode = kCAFillModeBoth;
    [self.innerRing1 addAnimation:innerRingRotate forKey:@"rotateInnerRing"];
    [self.innerRing2 addAnimation:innerRingRotate forKey:@"rotateInnerRing"];
}

- (void) beginAnimating {
    CABasicAnimation *outerRing1Rotate=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    outerRing1Rotate.fromValue=[NSNumber numberWithDouble:0.0f];
    outerRing1Rotate.toValue=[NSNumber numberWithDouble:0.25f];
    outerRing1Rotate.duration = 0.4f;
    outerRing1Rotate.repeatCount = 1;
    outerRing1Rotate.fillMode = kCAFillModeRemoved;
    [self.outerRing1 addAnimation:outerRing1Rotate forKey:@"rotateOuterRing"];
    
    CABasicAnimation *innerRing1Rotate=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    innerRing1Rotate.fromValue=[NSNumber numberWithDouble:0.25f];
    innerRing1Rotate.toValue=[NSNumber numberWithDouble:0.5f];
    innerRing1Rotate.duration = 0.4f;
    innerRing1Rotate.repeatCount = 1;
    innerRing1Rotate.fillMode = kCAFillModeRemoved;
    [self.innerRing1 addAnimation:innerRing1Rotate forKey:@"rotateInnerRing"];
    
    CABasicAnimation *outerRing2Rotate=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    outerRing2Rotate.fromValue=[NSNumber numberWithDouble:0.5f];
    outerRing2Rotate.toValue=[NSNumber numberWithDouble:0.75f];
    outerRing2Rotate.duration = 0.4f;
    outerRing2Rotate.repeatCount = 1;
    outerRing2Rotate.fillMode = kCAFillModeRemoved;
    [self.outerRing2 addAnimation:outerRing2Rotate forKey:@"rotateOuterRing"];
    
    CABasicAnimation *innerRing2Rotate=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    innerRing2Rotate.fromValue=[NSNumber numberWithDouble:0.75f];
    innerRing2Rotate.toValue=[NSNumber numberWithDouble:1.0f];
    innerRing2Rotate.duration = 0.4f;
    innerRing2Rotate.repeatCount = 1;
    innerRing2Rotate.fillMode = kCAFillModeRemoved;
    [self.innerRing2 addAnimation:innerRing2Rotate forKey:@"rotateInnerRing"];
    self.outerRing1.strokeEnd = self.outerRing1.strokeStart + 0.25f;
    self.outerRing2.strokeEnd = self.outerRing2.strokeStart + 0.25f;
    self.innerRing1.strokeEnd = self.innerRing1.strokeStart + 0.25f;
    self.innerRing2.strokeEnd = self.innerRing2.strokeStart + 0.25f;
    
        [self animate];
}

- (void) endAnimating:(void (^)())completionBlock {
    CABasicAnimation *outerRing1FadeOut=[CABasicAnimation animationWithKeyPath:@"strokeStart"];
    outerRing1FadeOut.fromValue=[NSNumber numberWithDouble:self.innerRing1.strokeStart];
    outerRing1FadeOut.toValue=[NSNumber numberWithDouble:self.innerRing1.strokeEnd];
    outerRing1FadeOut.duration = 0.3f;
    outerRing1FadeOut.repeatCount = 1;
    outerRing1FadeOut.fillMode = kCAFillModeForwards;
    [self.innerRing1 addAnimation:outerRing1FadeOut forKey:@"rotateOuterRing"];
    
    CABasicAnimation *innerRing1FadeOut=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    innerRing1FadeOut.fromValue=[NSNumber numberWithDouble:self.outerRing1.strokeEnd];
    innerRing1FadeOut.toValue=[NSNumber numberWithDouble:self.outerRing1.strokeStart];
    innerRing1FadeOut.duration = 0.3f;
    innerRing1FadeOut.repeatCount = 1;
    innerRing1FadeOut.fillMode = kCAFillModeForwards;
    [self.outerRing1 addAnimation:innerRing1FadeOut forKey:@"rotateInnerRing"];
    
    CABasicAnimation *outerRing2FadeOut=[CABasicAnimation animationWithKeyPath:@"strokeStart"];
    outerRing2FadeOut.fromValue=[NSNumber numberWithDouble:self.innerRing2.strokeStart];
    outerRing2FadeOut.toValue=[NSNumber numberWithDouble:self.innerRing2.strokeEnd];
    outerRing2FadeOut.duration = 0.3f;
    outerRing2FadeOut.repeatCount = 1;
    outerRing2FadeOut.fillMode = kCAFillModeForwards;
    [self.innerRing2 addAnimation:outerRing2FadeOut forKey:@"rotateOuterRing"];
    
    CABasicAnimation *innerRing2FadeOut=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    innerRing2FadeOut.fromValue=[NSNumber numberWithDouble:self.outerRing2.strokeEnd];
    innerRing2FadeOut.toValue=[NSNumber numberWithDouble:self.outerRing2.strokeStart];
    innerRing2FadeOut.duration = 0.3f;
    innerRing2FadeOut.repeatCount = 1;
    innerRing2FadeOut.fillMode = kCAFillModeForwards;
    [self.outerRing2 addAnimation:innerRing2FadeOut forKey:@"rotateInnerRing"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.outerRing1 removeAllAnimations];
        [self.outerRing2 removeAllAnimations];
        [self.innerRing1 removeAllAnimations];
        [self.innerRing2 removeAllAnimations];
        [self.outerRing1 removeFromSuperlayer];
        [self.outerRing2 removeFromSuperlayer];
        [self.innerRing1 removeFromSuperlayer];
        [self.innerRing2 removeFromSuperlayer];
        completionBlock();
    });
}


- (void)pauseAnimating {
    [self.outerRing1 removeAllAnimations];
    [self.outerRing2 removeAllAnimations];
    [self.innerRing1 removeAllAnimations];
    [self.innerRing2 removeAllAnimations];
}

- (void)setLineWidth:(CGFloat)width {
    self.outerRing1.lineWidth = width;
    self.outerRing2.lineWidth = width;
}

-(void) setInnerInset:(CGFloat)inset {
    CGFloat radius = MIN(self.frame.size.width,self.frame.size.height)/2;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, radius*2, radius*2);
    CGFloat outerInset  = 2;
    CGFloat innerInset  = (radius/2) + inset;
    self.innerRing1.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, innerInset, innerInset) cornerRadius:radius-outerInset].CGPath;
    self.innerRing2.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, innerInset, innerInset) cornerRadius:radius-outerInset].CGPath;
    
    self.innerRing1.lineWidth   = (radius-innerInset)*2;
    self.innerRing2.lineWidth   = (radius-innerInset)*2;

}

@end
