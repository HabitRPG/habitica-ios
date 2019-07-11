//
//  UIColor+LighterDarker.h
//  Habitica
//
//  Created by viirus on 16.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Habitica)

+ (nonnull UIColor *)purple10;
+ (nonnull UIColor *)purple50;
+ (nonnull UIColor *)purple100;
+ (nonnull UIColor *)purple200;
+ (nonnull UIColor *)purple300;
+ (nonnull UIColor *)purple400;
+ (nonnull UIColor *)purple500;
+ (nonnull UIColor *)purple600;

+ (nonnull UIColor *)darkRed10;
+ (nonnull UIColor *)darkRed50;
+ (nonnull UIColor *)darkRed100;
+ (nonnull UIColor *)darkRed500;

+ (nonnull UIColor *)red10;
+ (nonnull UIColor *)red50;
+ (nonnull UIColor *)red100;
+ (nonnull UIColor *)red500;

+ (nonnull UIColor *)orange10;
+ (nonnull UIColor *)orange50;
+ (nonnull UIColor *)orange100;
+ (nonnull UIColor *)orange500;

+ (nonnull UIColor *)yellow5;
+ (nonnull UIColor *)yellow10;
+ (nonnull UIColor *)yellow50;
+ (nonnull UIColor *)yellow100;
+ (nonnull UIColor *)yellow500;

+ (nonnull UIColor *)green10;
+ (nonnull UIColor *)green50;
+ (nonnull UIColor *)green100;
+ (nonnull UIColor *)green500;

+ (nonnull UIColor *)teal10;
+ (nonnull UIColor *)teal50;
+ (nonnull UIColor *)teal100;
+ (nonnull UIColor *)teal500;

+ (nonnull UIColor *)blue10;
+ (nonnull UIColor *)blue50;
+ (nonnull UIColor *)blue100;
+ (nonnull UIColor *)blue500;

+ (nonnull UIColor *)gray10;
+ (nonnull UIColor *)gray50;
+ (nonnull UIColor *)gray100;
+ (nonnull UIColor *)gray200;
+ (nonnull UIColor *)gray300;
+ (nonnull UIColor *)gray400;
+ (nonnull UIColor *)gray500;
+ (nonnull UIColor *)gray600;
+ (nonnull UIColor *)gray700;

+ (nonnull UIColor *)blackPurple50;
+ (nonnull UIColor *)blackPurple100;

+ (nonnull UIColor *)contributorColorFor:(NSInteger)level;

- (nullable UIColor *)blendWithColor:(nullable UIColor *)color2 alpha:(CGFloat)alpha2;

@end
