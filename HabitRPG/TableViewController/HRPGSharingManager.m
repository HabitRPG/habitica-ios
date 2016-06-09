//
//  HRPGSharingManager.m
//  Habitica
//
//  Created by Phillip Thelen on 25/04/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGSharingManager.h"

@implementation HRPGSharingManager

+ (void) shareItems:(NSArray *)items withPresentingViewController:(UIViewController *)presentingViewController {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [presentingViewController presentViewController:activityViewController animated:YES completion:nil];
}

+ (UIImage *)takeSnapshotOfView:(UIView *)view {
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
               afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
