//
//  HRPGRoundProgressView.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGRoundProgressView.h"

@interface HRPGRoundProgressView () {
    CGFloat startAngle;
    CGFloat endAngle;
    CGFloat animAngle;
}

@property CAShapeLayer *shapeLayer;
@property CADisplayLink *displayLink;
@property(nonatomic) CFTimeInterval firstTimestamp;

@end

@implementation HRPGRoundProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        animAngle = (M_PI * 2);
        self.indicatorStrokeColor = [UIColor colorWithRed:0.409 green:0.743 blue:0.037 alpha:1.000];
        self.backgroundStrokeColor = [UIColor colorWithWhite:0.85 alpha:1.000];
        self.strokeWidth = 4;
        self.roundTime = 1.2f;
        self.indicatorLength = 8;
    }
    return self;
}

- (void)beginAnimating {
    [self addShapeLayer];
    [self startDisplayLink];
}

- (void)addShapeLayer {
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = [[self pathAtInterval:0.0] CGPath];
    self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.shapeLayer.lineWidth = self.strokeWidth;
    self.shapeLayer.strokeColor = [self.indicatorStrokeColor CGColor];
    self.shapeLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:self.shapeLayer];
}

- (void)startDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    if (!self.firstTimestamp)
        self.firstTimestamp = displayLink.timestamp;

    NSTimeInterval elapsed = (displayLink.timestamp - self.firstTimestamp);
    CGFloat elapsedFraction = fmod(elapsed, self.roundTime);
    CGFloat elapsedPercent = (elapsedFraction / self.roundTime);
    self.shapeLayer.path = [[self pathAtInterval:elapsedPercent] CGPath];
}

- (UIBezierPath *)pathAtInterval:(NSTimeInterval)interval {
    UIBezierPath *indicatorPath = [UIBezierPath bezierPath];

    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    float radius = (self.frame.size.width - self.strokeWidth) / 2;

    [indicatorPath addArcWithCenter:center
                             radius:radius
                         startAngle:startAngle + (animAngle * interval)
                           endAngle:startAngle + (animAngle * interval) + (self.indicatorLength / 100.0) * endAngle
                          clockwise:YES];
    return indicatorPath;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *backgroundPath = [UIBezierPath bezierPath];

    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    float radius = (rect.size.width - self.strokeWidth) / 2;
    [backgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    backgroundPath.lineWidth = self.strokeWidth;
    [self.backgroundStrokeColor setStroke];
    [backgroundPath stroke];
}


@end
