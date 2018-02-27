//
//  HRPGLabeledProgressBar.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGLabeledProgressBar.h"
#import "Habitica-Swift.h"

@interface HRPGLabeledProgressBar ()

@property ProgressBar *progressBar;
@property NSNumberFormatter *numberFormatter;

@end

@implementation HRPGLabeledProgressBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self initViews];
    }

    return self;
}

- (void)initViews {
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.generatesDecimalNumbers = true;
    self.numberFormatter.usesGroupingSeparator = true;
    self.numberFormatter.maximumFractionDigits = 1;
    self.numberFormatter.minimumIntegerDigits = 1;

    self.color = [UIColor blackColor];

    self.progressBar = [[ProgressBar alloc] init];
    [self addSubview:self.progressBar];
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeLeft;
    self.iconView.tintColor = [UIColor blackColor];
    [self addSubview:self.iconView];
    self.labelView = [[UILabel alloc] init];
    self.labelView.textAlignment = NSTextAlignmentLeft;
    self.labelView.textColor = [UIColor darkGrayColor];
    [self addSubview:self.labelView];
    self.typeView = [[UILabel alloc] init];
    self.typeView.textAlignment = NSTextAlignmentRight;
    self.typeView.textColor = [UIColor darkGrayColor];
    [self addSubview:self.typeView];
    self.fontSize = 11;
    NSOperatingSystemVersion ios10_0_0 = (NSOperatingSystemVersion){10, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_0_0]) {
        self.labelView.adjustsFontForContentSizeCategory = YES;
        self.typeView.adjustsFontForContentSizeCategory = YES;
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;

    self.progressBar.barColor = color;
    self.iconView.tintColor = color;
}

- (void)setIcon:(UIImage *)icon {
    self.iconView.image = icon;
}

- (void)setValue:(NSNumber *)value {
    _value = value;
    [self setLabelViewText];
    [self.progressBar setBarValue:[value floatValue] animated:YES];
}

- (void)setMaxValue:(NSNumber *)maxValue {
    _maxValue = maxValue;
    [self setLabelViewText];
    self.progressBar.maxValue = [maxValue floatValue];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateViewFrames];
}

- (void)setType:(NSString *)type {
    _type = type;
    self.typeView.text = self.type;
    [self updateViewFrames];
    [self applyAccessibility];
}

- (void)setLabelViewText {
    NSNumber *currentValue = self.value;
    if ([self.value floatValue] > 1 || [self.value floatValue] < 0) {
        currentValue =[[NSNumber alloc] initWithDouble:floor([self.value floatValue])];
    } else {
        currentValue =[[NSNumber alloc] initWithDouble:ceil([self.value floatValue] * 10) / 10];
    }
    self.labelView.text = [NSString stringWithFormat:@"%@ / %@", [self.numberFormatter stringFromNumber:currentValue],  [self.numberFormatter stringFromNumber:self.maxValue]];

    [self applyAccessibility];
}

- (void)setFontSize:(NSInteger)fontSize {
    UIFont *scaledFont = [CustomFontMetrics scaledSystemFontOfSize:fontSize compatibleWith:nil];
    _fontSize = (NSInteger) scaledFont.pointSize;
    self.typeView.font = scaledFont;
    self.labelView.font = scaledFont;
    [self updateViewFrames];
}
- (void)updateViewFrames {
    self.iconView.frame = CGRectMake(0, 0, 18, 18);
    self.progressBar.frame = CGRectMake(24, 1, self.frame.size.width - 24, 16);
    self.labelView.frame = CGRectMake(25, 19, (self.frame.size.width - 25) / 2, self.fontSize + 1);
    self.typeView.frame = CGRectMake((self.frame.size.width + 25) / 2, 19,
                                     (self.frame.size.width - 25) / 2, self.fontSize + 1);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.progressBar setNeedsDisplay];
    [self updateViewFrames];
}

- (void)setIsActive:(BOOL)isActive {
    if (isActive) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.4;
    }
    [self applyAccessibility];
}

- (BOOL)isActive {
    return true;
}

- (void)applyAccessibility {
    self.isAccessibilityElement = self.isActive;
    
    self.shouldGroupAccessibilityChildren = true;
    self.labelView.isAccessibilityElement = false;
    self.typeView.isAccessibilityElement = false;
    
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %ld of %@", self.typeView.text, (long)[self.value integerValue], self.maxValue];
}

@end
