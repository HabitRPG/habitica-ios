//
//  HRPGLabeledProgressBar.h
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGProgressBar.h"

IB_DESIGNABLE
@interface HRPGLabeledProgressBar : UIView

@property UIImageView *iconView;
@property UILabel *labelView;
@property UILabel *typeView;
@property HRPGProgressBar *progressBar;

@property BOOL isActive;

@property(nonatomic) UIColor *color;
@property(nonatomic) NSNumber *maxValue;
@property(nonatomic) NSNumber *value;
@property(nonatomic) NSString *type;
@property(nonatomic) UIImage *icon;
@property(nonatomic) NSInteger fontSize;

@end
