//
//  HRPGProgressBar.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGProgressBar.h"

@interface HRPGProgressBar ()

@property CGFloat value;
@property CGFloat maxValue;

@end

@implementation HRPGProgressBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.barColor = [UIColor blackColor];
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.000];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 0.5;
    }
    
    return self;
}

- (CGFloat)getBarValue {
    return self.value;
}

- (void)setBarValue:(CGFloat)newValue animated:(BOOL)animated {
    self.value = newValue;
    [self setNeedsDisplay];
}

- (void)setMaxBarValue:(CGFloat)newMaxValue {
    self.maxValue = newMaxValue;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGFloat percent = self.value / self.maxValue;
    CGRect rectangle = CGRectMake(rect.origin.x, rect.origin.y, (rect.size.width * percent), rect.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.barColor CGColor]);
    CGContextFillRect(context, rectangle);
}


@end
