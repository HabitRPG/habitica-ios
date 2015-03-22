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

@synthesize size = _size;
@synthesize checked = _checked;
@synthesize boxColor = _boxColor;
@synthesize checkColor = _checkColor;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.size = 17;
        self.boxColor = [UIColor blackColor];
        self.checkColor = [UIColor blackColor];
        
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
        scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(-3.f, -3.f)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        scaleAnimation.springBounciness = 18.0f;
        scaleAnimation.beginTime = 0.5f;
        [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
        self.wasTouched();
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, [self.boxColor CGColor]);
    CGContextStrokeRect(ctx, CGRectMake(self.frame.size.width/2-self.size/2, self.frame.size.height/2-self.size/2, self.size, self.size));
    if (self.checked) {
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, 3);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetStrokeColorWithColor(ctx, [self.checkColor CGColor]);
        CGContextMoveToPoint(ctx, self.frame.size.width/2-(self.size/3), self.frame.size.height/2);
        CGContextAddLineToPoint(ctx, self.frame.size.width/2, self.frame.size.height/2+(self.size/3));
        CGContextAddLineToPoint(ctx, self.frame.size.width/2+(self.size/4)*3, self.frame.size.height/2-(self.size/4)*2);
        CGContextStrokePath(ctx);
    }
}


@end
