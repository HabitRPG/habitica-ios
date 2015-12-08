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
        self.backgroundColor = [UIColor clearColor];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *trackPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:8.0f];
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.8549 alpha:1.0] CGColor]);
    [trackPath fill];
    CGFloat percent = self.value / self.maxValue;
    if (self.maxValue == 0 || percent < 0) {
        percent = 0;
    }
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width*percent, rect.size.height) cornerRadius:8.0f];
    CGContextSetFillColorWithColor(context, [self.barColor CGColor]);
    [trackPath addClip];
    [fillPath fill];
}


@end
