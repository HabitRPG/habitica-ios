//
//  HRPGHoledView.m
//  Habitica
//
//  Created by Phillip Thelen on 13/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGHoledView.h"

@implementation HRPGHoledView

- (instancetype)init {
    self = [super init];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        [self setContentMode:UIViewContentModeRedraw];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    [self.dimColor setFill];
    UIRectFill(rect);

    if (!CGRectIsEmpty(self.highlightedFrame)) {
        CGRect holeRectIntersection = CGRectIntersection(self.highlightedFrame, rect);
        [[UIColor clearColor] setFill];
        UIRectFill(holeRectIntersection);
    }
}

@end
