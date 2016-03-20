//
//  UIView+Pulse.m
//  Habitica
//
//  Created by Phillip Thelen on 30/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "UIView+Pulse.h"

@implementation UIView (Pulse)

- (void)pulse {
    [self pulseWithColor:self.backgroundColor];
}

- (void)pulseWithColor:(UIColor *)color {
    UIView *pulseView = [[UIView alloc] initWithFrame:[self convertRect:self.bounds fromView:nil]];
    pulseView.backgroundColor = color;
    CGFloat scaleWidth = pulseView.frame.size.width / 3;
    CGFloat scaleHeight = pulseView.frame.size.height / 3;
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:pulseView];
    [UIView animateWithDuration:0.2
        animations:^() {
            pulseView.frame = CGRectMake(pulseView.frame.origin.x - scaleWidth,
                                         pulseView.frame.origin.y - scaleHeight,
                                         pulseView.frame.size.width + (scaleWidth * 2),
                                         pulseView.frame.size.height + (scaleHeight * 2));
            pulseView.alpha = 0;
        }
        completion:^(BOOL completed) {
            [pulseView removeFromSuperview];
        }];
}

@end
