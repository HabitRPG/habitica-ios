//
//  UIColor+LighterDarker.h
//  Habitica
//
//  Created by viirus on 16.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Habitica)

+ (UIColor *)purple50;
+ (UIColor *)purple100;
+ (UIColor *)purple200;
+ (UIColor *)purple300;
+ (UIColor *)purple400;
+ (UIColor *)purple500;
+ (UIColor *)purple600;

+ (UIColor *)darkRed10;
+ (UIColor *)darkRed50;
+ (UIColor *)darkRed100;
+ (UIColor *)darkRed500;

+ (UIColor *)red10;
+ (UIColor *)red50;
+ (UIColor *)red100;
+ (UIColor *)red500;

+ (UIColor *)orange10;
+ (UIColor *)orange50;
+ (UIColor *)orange100;
+ (UIColor *)orange500;

+ (UIColor *)yellow5;
+ (UIColor *)yellow10;
+ (UIColor *)yellow50;
+ (UIColor *)yellow100;
+ (UIColor *)yellow500;

+ (UIColor *)green10;
+ (UIColor *)green50;
+ (UIColor *)green100;
+ (UIColor *)green500;

+ (UIColor *)teal10;
+ (UIColor *)teal50;
+ (UIColor *)teal100;
+ (UIColor *)teal500;

+ (UIColor *)blue10;
+ (UIColor *)blue50;
+ (UIColor *)blue100;
+ (UIColor *)blue500;

+ (UIColor *)gray10;
+ (UIColor *)gray50;
+ (UIColor *)gray100;
+ (UIColor *)gray200;
+ (UIColor *)gray300;
+ (UIColor *)gray400;
+ (UIColor *)gray500;
+ (UIColor *)gray600;
+ (UIColor *)gray700;

- (UIColor *)blendWithColor:(UIColor *)color2 alpha:(CGFloat)alpha2;

@end
