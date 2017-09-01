//
//  CAGradientLayer+HRPGShopGradient.m
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "CAGradientLayer+HRPGShopGradient.h"
#import "UIColor+Habitica.h"

@implementation CAGradientLayer (HRPGShopGradient)

+ (CAGradientLayer *)hrpgShopGradientLayer{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor purple50].CGColor];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    return gradient;
}

@end
