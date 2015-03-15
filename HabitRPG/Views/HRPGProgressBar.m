//
//  HRPGProgressBar.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGProgressBar.h"

@implementation HRPGProgressBar

CGFloat value;
CGFloat maxValue;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.barColor = [UIColor blackColor];
        self.backgroundColor = [UIColor lightGrayColor];
        value = 0;
    }
    
    return self;
}

- (CGFloat)getBarValue {
    return value;
}

- (void)setBarValue:(CGFloat)newValue animated:(BOOL)animated {
    value = newValue;
    [self setNeedsDisplay];
}

- (void)setMaxBarValue:(CGFloat)newMaxValue {
    maxValue = newMaxValue;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect rectangle = CGRectMake(rect.origin.x, rect.origin.y, (rect.size.width / 100 * value), rect.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.barColor CGColor]);
    CGContextFillRect(context, rectangle);
}


@end
