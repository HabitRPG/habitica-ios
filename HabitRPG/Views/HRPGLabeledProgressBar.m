//
//  HRPGLabeledProgressBar.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGLabeledProgressBar.h"
#import "HRPGProgressBar.h"

@interface HRPGLabeledProgressBar ()

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
    self.color = [UIColor blackColor];

    self.progressBar = [[HRPGProgressBar alloc] init];
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
    [self.progressBar setMaxBarValue:[maxValue floatValue]];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateViewFrames];
}

- (void)setType:(NSString *)type {
    _type = type;
    self.typeView.text = self.type;
    [self updateViewFrames];
}

- (void)setLabelViewText {
    if ([self.value floatValue] < 1) {
        self.labelView.text =
            [NSString stringWithFormat:@"%.1f / %@", [self.value floatValue], self.maxValue];
    } else {
        self.labelView.text =
            [NSString stringWithFormat:@"%ld / %@", (long)[self.value integerValue], self.maxValue];
    }
}

- (void)setFontSize:(NSInteger)fontSize {
    _fontSize = fontSize;
    self.typeView.font = [UIFont systemFontOfSize:fontSize];
    self.labelView.font = [UIFont systemFontOfSize:fontSize];
    [self updateViewFrames];
}
- (void)updateViewFrames {
    self.iconView.frame = CGRectMake(0, 0, 16, 16);
    self.progressBar.frame = CGRectMake(31, 0, self.frame.size.width - 31, 16);
    self.labelView.frame = CGRectMake(33, 18, (self.frame.size.width - 33) / 2, self.fontSize + 1);
    self.typeView.frame = CGRectMake((self.frame.size.width + 33) / 2, 18,
                                     (self.frame.size.width - 33) / 2, self.fontSize + 1);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateViewFrames];
}

@end
