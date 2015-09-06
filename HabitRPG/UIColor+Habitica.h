//
//  UIColor+LighterDarker.h
//  Habitica
//
//  Created by viirus on 16.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Habitica)

+ (UIColor *)purple50;
+ (UIColor *)purple100;
+ (UIColor *)purple200;
+ (UIColor *)purple300;
+ (UIColor *)purple400;
+ (UIColor *)purple500;

+ (UIColor *)darkRed10;
+ (UIColor *)darkRed50;
+ (UIColor *)darkRed100;

+ (UIColor *)red10;
+ (UIColor *)red50;
+ (UIColor *)red100;

+ (UIColor *)orange10;
+ (UIColor *)orange50;
+ (UIColor *)orange100;

+ (UIColor *)yellow10;
+ (UIColor *)yellow50;
+ (UIColor *)yellow100;

+ (UIColor *)green10;
+ (UIColor *)green50;
+ (UIColor *)green100;

+ (UIColor *)teal10;
+ (UIColor *)teal50;
+ (UIColor *)teal100;

+ (UIColor *)blue10;
+ (UIColor *)blue50;
+ (UIColor *)blue100;

+ (UIColor *)gray50;
+ (UIColor *)gray100;
+ (UIColor *)gray200;
+ (UIColor *)gray300;
+ (UIColor *)gray400;
+ (UIColor *)gray500;
+ (UIColor *)gray600;


- (UIColor*)blendWithColor:(UIColor*)color2 alpha:(CGFloat)alpha2;

@end
