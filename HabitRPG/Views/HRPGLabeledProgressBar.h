//
//  HRPGLabeledProgressBar.h
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGLabeledProgressBar : UIView

@property (nonatomic) UIColor *color;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger value;
@property (nonatomic) UIImage *icon;

@end
