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
@property UIImageView *iconView;
@property UILabel *labelView;
@property HRPGProgressBar *progressBar;

@end


@implementation HRPGLabeledProgressBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.color = [UIColor blackColor];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.iconView];
        self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, self.frame.size.width, 20)];
        [self addSubview:self.labelView];
        self.progressBar = [[HRPGProgressBar alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 5)];
        [self addSubview:self.progressBar];
    }
    
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    
    self.iconView.tintColor = color;
    self.labelView.textColor = color;
    self.progressBar.barColor = color;
}

- (void)setIcon:(UIImage *)icon {
    self.iconView.image = icon;
}

- (void)setValue:(NSInteger)value {
    _value = value;
    [self setLabelViewText];
    [self.progressBar setBarValue:value animated:YES];
}

- (void)setMaxValue:(NSInteger)maxValue {
    _maxValue = maxValue;
    [self setLabelViewText];
    [self.progressBar setMaxBarValue:maxValue];
}

- (void) setLabelViewText {
    self.labelView.text = [NSString stringWithFormat:@"%ld/%ld", (long) self.value, self.maxValue];
}

@end
