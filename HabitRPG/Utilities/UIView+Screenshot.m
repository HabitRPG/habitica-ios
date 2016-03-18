//
//  UIView+Screenshot.m
//  Habitica
//
//  Created by Phillip Thelen on 11/04/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)pb_takeScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);

    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];

    // old style [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
