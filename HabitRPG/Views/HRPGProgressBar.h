//
//  HRPGProgressBar.h
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGProgressBar : UIView

@property UIColor *barColor;

- (void) setBarValue:(CGFloat) value animated:(BOOL)animated;
- (CGFloat) getBarValue;

- (void) setMaxBarValue:(CGFloat) maxValue;

@end
