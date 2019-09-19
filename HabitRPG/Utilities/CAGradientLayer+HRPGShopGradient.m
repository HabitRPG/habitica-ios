//
//  CAGradientLayer+HRPGShopGradient.m
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "CAGradientLayer+HRPGShopGradient.h"
#import "Habitica-Swift.h"

@implementation CAGradientLayer (HRPGShopGradient)

+ (CAGradientLayer *)hrpgShopGradientLayer{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[ObjcThemeWrapper dimmBackgroundColor].CGColor];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    return gradient;
}

@end
