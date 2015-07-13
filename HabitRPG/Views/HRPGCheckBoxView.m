//
//  HRPGCheckBoxView.m
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCheckBoxView.h"
#import <pop/POP.h>
@interface HRPGCheckBoxView ()

@end

@implementation HRPGCheckBoxView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.size = 25;
        self.boxColor = [UIColor blackColor];
        self.checkColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];

    }
    
    return self;
}

- (void)setChecked:(bool)isChecked {
    _checked = isChecked;
    [self setNeedsDisplay];
}

- (void)setChecked:(bool)isChecked animated:(bool)animated {
    self.checked = isChecked;
}

- (void)setSize:(CGFloat)newSize {
    _size = newSize;
    [self setNeedsDisplay];
}

- (void)setCheckUIColor:(UIColor *)checkColor {
    _checkColor = checkColor;
    [self setNeedsDisplay];
}

- (void)setBoxUIColor:(UIColor *)boxColor {
    _boxColor = boxColor;
    [self setNeedsDisplay];
}

- (void)viewTapped:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(-6.f, -6.f)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        scaleAnimation.springBounciness = 18.0f;
        scaleAnimation.beginTime = 0.5f;
        [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
        self.wasTouched();
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.boxColor setStroke];
    [self.boxColor setFill];
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2-self.size/2, self.frame.size.height/2-self.size/2, self.size, self.size) cornerRadius:3];
    [rectPath stroke];
    if (self.checked) {
        [rectPath fill];
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, 4);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetStrokeColorWithColor(ctx, [self.checkColor CGColor]);
        CGContextMoveToPoint(ctx, self.frame.size.width/2-(self.size/3.5), self.frame.size.height/2);
        CGContextAddLineToPoint(ctx, self.frame.size.width/2-(self.size/8), self.frame.size.height/2+(self.size/5));
        CGContextAddLineToPoint(ctx, self.frame.size.width/2+(self.size/4), self.frame.size.height/2-(self.size/5));
        CGContextStrokePath(ctx);
    } else {
    }
}


@end
