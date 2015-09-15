//
//  HRPGCheckBoxView.m
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCheckBoxView.h"
#import <pop/POP.h>
#import "UIColor+Habitica.h"

@interface HRPGCheckBoxView ()
@property (nonatomic) CGFloat size;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) bool checked;
@property (nonatomic) UIColor *boxBorderColor;
@property (nonatomic) UIColor *boxFillColor;
@property (nonatomic) UIColor *checkColor;
@end

@implementation HRPGCheckBoxView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.size = 26;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];

    }
    
    return self;
}

- (void)configureForTask:(Task *)task {
    self.boxFillColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.checked = [task.completed boolValue];
    if ([task.type isEqualToString:@"daily"]) {
        self.cornerRadius = 3;
        
        if ([task.completed boolValue]) {
            self.boxBorderColor = [UIColor gray50];
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray100];
            self.checkColor = [UIColor gray200];
        } else {
            if ([task dueToday]) {
                self.backgroundColor = [task lightTaskColor];
                self.boxBorderColor = [task taskColor];
            } else {
                self.boxBorderColor = [UIColor gray50];
                self.backgroundColor = [UIColor gray100];
                self.checkColor = [UIColor gray200];
            }
        }
        
    } else {
        self.cornerRadius = self.size/2;
        if ([task.completed boolValue]) {
            self.boxBorderColor = [UIColor gray50];
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray100];
            self.checkColor = [UIColor gray200];
        } else {
            self.boxBorderColor = [task taskColor];
            self.backgroundColor = [task lightTaskColor];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)configureForChecklistItem:(ChecklistItem *)item forTask:(Task *)task {
    self.checked = [item.completed boolValue];
    self.backgroundColor = [UIColor clearColor];
    self.boxBorderColor = [UIColor gray50];
    self.boxFillColor = [UIColor gray400];
    self.checkColor = [UIColor gray200];
    if ([task.type isEqualToString:@"daily"]) {
        self.cornerRadius = 3;
    } else {
        self.cornerRadius = self.size/2;
    }
    [self setNeedsDisplay];
}

- (void)viewTapped:(UITapGestureRecognizer*)recognizer {
    self.wasTouched();
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.boxBorderColor setStroke];
    [self.boxFillColor setFill];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2-self.size/2, self.frame.size.height/2-self.size/2, self.size, self.size) cornerRadius:self.cornerRadius];
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(borderPath.bounds.origin.x+1, borderPath.bounds.origin.y+1, borderPath.bounds.size.width-2, borderPath.bounds.size.height-2) cornerRadius:self.cornerRadius];
    [borderPath setLineWidth:2];
    [borderPath stroke];
    [fillPath fill];
    if (self.checked) {
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, 2);
        CGContextSetStrokeColorWithColor(ctx, [self.checkColor CGColor]);
        CGContextMoveToPoint(ctx, self.frame.size.width/2-(self.size/3.5), self.frame.size.height/2);
        CGContextAddLineToPoint(ctx, self.frame.size.width/2-(self.size/8), self.frame.size.height/2+(self.size/5));
        CGContextAddLineToPoint(ctx, self.frame.size.width/2+(self.size/4), self.frame.size.height/2-(self.size/5));
        CGContextStrokePath(ctx);
    } else {
    }
}


@end
