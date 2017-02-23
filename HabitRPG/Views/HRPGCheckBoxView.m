//
//  HRPGCheckBoxView.m
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCheckBoxView.h"
#import "UIColor+Habitica.h"

@interface HRPGCheckBoxView ()

@end

@implementation HRPGCheckBoxView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.size = 26;

        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
    }

    return self;
}

- (void)configureForTask:(Task *)task {
    [self configureForTask:task withOffset:0];
}

- (void)configureForTask:(Task *)task withOffset:(NSInteger)offset {
    self.boxFillColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.checked = [task.completed boolValue];
    if ([task.type isEqualToString:@"daily"]) {
        self.cornerRadius = 3;

        if ([task.completed boolValue]) {
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray100];
            self.checkColor = [UIColor gray200];
        } else {
            if ([task dueTodayWithOffset:offset]) {
                self.backgroundColor = [task lightTaskColor];
                self.checkColor = [task taskColor];
            } else {
                self.backgroundColor = [UIColor gray100];
                self.checkColor = [UIColor gray200];
            }
        }

    } else {
        self.cornerRadius = self.size / 2;
        if ([task.completed boolValue]) {
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray100];
            self.checkColor = [UIColor gray200];
        } else {
            self.backgroundColor = [task lightTaskColor];
            self.checkColor = [task taskColor];
        }
    }

    [self setNeedsDisplay];
}

- (void)configureForChecklistItem:(ChecklistItem *)item forTask:(Task *)task {
    self.checked = [item.completed boolValue] || [item.currentlyChecking boolValue];
    self.backgroundColor = [UIColor clearColor];
    self.boxFillColor = [UIColor gray400];
    self.checkColor = [UIColor gray200];
    if ([task.type isEqualToString:@"daily"]) {
        self.cornerRadius = 3;
    } else {
        self.cornerRadius = self.size / 2;
    }
    [self setNeedsDisplay];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    self.checked = !self.checked;
    if (self.wasTouched) {
        self.wasTouched();
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.boxFillColor setFill];
    UIBezierPath *borderPath = [UIBezierPath
        bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 2 - self.size / 2,
                                             self.frame.size.height / 2 - self.size / 2, self.size,
                                             self.size)
                     cornerRadius:self.cornerRadius];
    [borderPath fill];
    if (self.checked) {
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, 2);
        CGContextSetStrokeColorWithColor(ctx, [self.checkColor CGColor]);
        CGContextMoveToPoint(ctx, self.frame.size.width / 2 - (self.size / 3.5),
                             self.frame.size.height / 2);
        CGContextAddLineToPoint(ctx, self.frame.size.width / 2 - (self.size / 8),
                                self.frame.size.height / 2 + (self.size / 5));
        CGContextAddLineToPoint(ctx, self.frame.size.width / 2 + (self.size / 4),
                                self.frame.size.height / 2 - (self.size / 5));
        CGContextStrokePath(ctx);
    } else {
    }
}

@end
