//
//  UIImage+withColor.m
//  Habitica
//
//  Created by Phillip Thelen on 20/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "UIImage+withColor.h"

@implementation UIImage (withColor)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
