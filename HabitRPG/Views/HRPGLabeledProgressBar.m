//
//  HRPGLabeledProgressBar.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Habitica-Swift.h"
#import "HRPGLabeledProgressBar.h"

@interface HRPGLabeledProgressBar ()

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

    self.progressBar = [[ProgressBar alloc] initWithFrame:CGRectZero];
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.progressBar];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.tintColor = [UIColor blackColor];
    [self addSubview:self.iconView];
    
    self.labelView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelView.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelView.textColor = [UIColor darkGrayColor];
    [self addSubview:self.labelView];
    
    self.typeView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.typeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeView.textColor = [UIColor darkGrayColor ];
    
    [self addSubview:self.typeView];
    self.fontSize = 11;

    self.labelView.adjustsFontForContentSizeCategory = YES;
    self.typeView.adjustsFontForContentSizeCategory = YES;
    
    UIUserInterfaceLayoutDirection direction = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute];
    if (direction == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.progressBar.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    } else {
        self.progressBar.transform = CGAffineTransformIdentity;
    }
    
    [self setupConstraints];
}

-(void)setupConstraints {
    
    // iconView placement and size
    [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.iconView.widthAnchor constraintEqualToConstant:18.0].active = YES;
    [self.iconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.iconView.heightAnchor constraintEqualToConstant:18.0].active = YES;
    
    // progressBar placement and size
    [self.progressBar.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:6.0].active = YES;
    [self.progressBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

    [self.progressBar.heightAnchor constraintEqualToConstant:8.0].active = YES;
    [self.progressBar.topAnchor constraintEqualToAnchor:self.iconView.topAnchor].active = YES;
    
    // label sizes will be intrinsic
    
    // labelView and typeView placement (horizontal):
    [self.labelView.leadingAnchor constraintEqualToAnchor:self.progressBar.leadingAnchor constant:1.0].active = YES;
    [self.typeView.trailingAnchor constraintEqualToAnchor:self.progressBar.trailingAnchor constant:-1.0].active = YES;
    
    // Keep labelView to smallest possible size, this prevents need for alignment
    [self.labelView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.typeView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    // Favor showing all of the typeView label if combined is too big; this only kicks in if label is very long
    [self.labelView setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    
    // Labels Placement (vertical)
    
    [self.labelView.topAnchor constraintEqualToAnchor:self.progressBar.bottomAnchor constant:2.0].active = YES;
    [self.typeView.topAnchor constraintEqualToAnchor:self.progressBar.bottomAnchor constant:2.0].active = YES;
    [self.labelView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.typeView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
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

- (void)setType:(NSString *)type {
    _type = type;
    self.typeView.text = self.type;
    [self applyAccessibility];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.labelView.textColor = textColor;
    self.typeView.textColor = textColor;
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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.progressBar setNeedsDisplay];
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
