//
//  HRPGBall.m
//  RabbitRPG
//
//  Created by Phillip on 08/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBall.h"

@implementation HRPGBall

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *ball = [UIBezierPath bezierPathWithOvalInRect:rect];
    [self.ballColor setFill];
    [ball fill];
}


@end
