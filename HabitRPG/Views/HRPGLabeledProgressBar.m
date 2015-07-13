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

- (void) initViews {
    self.color = [UIColor blackColor];
    
    self.progressBar = [[HRPGProgressBar alloc] initWithFrame:CGRectMake(20, 2, self.frame.size.width-20, self.frame.size.height-4)];
    [self addSubview:self.progressBar];
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 20, self.frame.size.height-4)];
    self.iconView.contentMode = UIViewContentModeLeft;
    self.iconView.tintColor = [UIColor blackColor];
    [self addSubview:self.iconView];
    self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, self.frame.size.width-25, self.frame.size.height-4)];
    self.labelView.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.labelView];
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

- (void) setLabelViewText {
    if ([self.value floatValue] < 1) {
        self.labelView.text = [NSString stringWithFormat:@"%.1f / %@", [self.value floatValue], self.maxValue];
    } else {
        self.labelView.text = [NSString stringWithFormat:@"%ld / %@", (long) [self.value integerValue], self.maxValue];
    }
}

- (void) updateViewFrames {
    self.labelView.frame = CGRectMake(20, 2, self.frame.size.width-25, self.frame.size.height-4);
    self.progressBar.frame = CGRectMake(20, 2, self.frame.size.width-20, self.frame.size.height-4);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateViewFrames];
}

@end
