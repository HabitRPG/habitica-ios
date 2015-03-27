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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
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
    
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    
    self.progressBar.barColor = color;
    self.iconView.tintColor = color;
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.labelView.frame = CGRectMake(20, 2, self.frame.size.width-25, self.frame.size.height-4);
    self.progressBar.frame = CGRectMake(20, 2, self.frame.size.width-20, self.frame.size.height-4);
}

- (void) setLabelViewText {
    self.labelView.text = [NSString stringWithFormat:@"%ld / %ld", (long) self.value, self.maxValue];
}

@end
