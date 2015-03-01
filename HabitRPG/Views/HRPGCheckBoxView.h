//
//  HRPGCheckBoxView.h
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGCheckBoxView : UIView

@property (nonatomic) CGFloat size;
@property (nonatomic) bool checked;
@property (nonatomic) UIColor *boxColor;
@property (nonatomic) UIColor *checkColor;
@property (copy)void (^wasTouched)(void);

- (void)setChecked:(bool)isChecked animated:(bool)animated;

@end
