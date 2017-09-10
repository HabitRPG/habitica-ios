//
//  HRPGCheckBoxView.m
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCheckBoxView.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGCheckBoxView ()

@property UILabel *label;

@end

@implementation HRPGCheckBoxView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void) setupView {
    self.backgroundColor = [UIColor clearColor];
    self.size = 26;
    self.padding = 12;
    self.centerCheckbox = true;
    self.borderedBox = false;
    
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
    
    self.userInteractionEnabled = false;
}

- (void)configureForTask:(Task *)task {
    [self configureForTask:task withOffset:0];
}

- (void)configureForTask:(Task *)task withOffset:(NSInteger)offset {
    self.boxFillColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.checked = task.completed;
    if ([task.type isEqualToString:@"daily"]) {
        self.cornerRadius = 3;

        if (task.completed) {
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray500];
            self.checkColor = [UIColor gray200];
        } else {
            if (task.isDue) {
                self.backgroundColor = [task lightTaskColor];
                self.checkColor = [task taskColor];
            } else {
                self.backgroundColor = [UIColor gray600];
                self.checkColor = [UIColor gray200];
            }
        }

    } else {
        self.cornerRadius = self.size / 2;
        if (task.completed) {
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray600];
            self.checkColor = [UIColor gray200];
        } else {
            self.backgroundColor = [task lightTaskColor];
            self.checkColor = [task taskColor];
        }
    }

    [self setNeedsDisplay];
}

- (void)configureForChecklistItem:(ChecklistItem *)item withTitle:(BOOL)withTitle {
    self.checked = [item.completed boolValue] || [item.currentlyChecking boolValue];
    if (self.label == nil && withTitle) {
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        [self addSubview:self.label];
        
        if (self.checked) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:item.text];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            self.label.attributedText = attributeString;
        } else {
            self.label.text = item.text;
        }
    }
    
    self.label.textColor = self.checked ? [UIColor gray400] : [UIColor gray100];
    self.backgroundColor = [UIColor clearColor];
    self.boxFillColor = self.checked ? [UIColor gray400] : [UIColor clearColor];
    self.boxBorderColor = self.checked ? nil : [UIColor gray400];
    self.checkColor = [UIColor gray200];
    self.cornerRadius = 3;
    self.centerCheckbox = NO;
    self.size = 22;
    self.borderedBox = true;
    [self setNeedsDisplay];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    if (self.wasTouched) {
        self.checked = !self.checked;
        self.wasTouched();
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews {
    CGFloat leftOffset = self.padding*2 + self.size;
    self.label.frame = CGRectMake(leftOffset, 0, self.frame.size.width-leftOffset, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat horizontalCenter = self.centerCheckbox ? self.frame.size.width / 2 : self.padding + self.size / 2;
    UIBezierPath *borderPath = [UIBezierPath
        bezierPathWithRoundedRect:CGRectMake(horizontalCenter - self.size / 2,
                                             self.frame.size.height / 2 - self.size / 2, self.size,
                                             self.size)
                     cornerRadius:self.cornerRadius];
    if (self.boxBorderColor != nil) {
        [self.boxBorderColor setStroke];
        [borderPath stroke];
    }
    [self.boxFillColor setFill];
    [borderPath fill];
    if (self.checked) {
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, 2);
        CGContextSetStrokeColorWithColor(ctx, [self.checkColor CGColor]);
        CGContextMoveToPoint(ctx, horizontalCenter - (self.size / 3.5),
                             self.frame.size.height / 2);
        CGContextAddLineToPoint(ctx, horizontalCenter - (self.size / 8),
                                self.frame.size.height / 2 + (self.size / 5));
        CGContextAddLineToPoint(ctx, horizontalCenter + (self.size / 4),
                                self.frame.size.height / 2 - (self.size / 5));
        CGContextStrokePath(ctx);
    } else {
    }
}

- (void)setWasTouched:(void (^)(void))wasTouched {
    _wasTouched = wasTouched;
    if (wasTouched != nil) {
        self.userInteractionEnabled = true;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.size+self.padding*2, self.size+self.padding*2);
}

@end
