//
//  HRPGLoadingSquaresSegue.m
//  Habitica
//
//  Created by Phillip Thelen on 19/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGLoadingSquaresSegue.h"
#import "HRPGLoadingViewController.h"

@implementation HRPGLoadingSquaresSegue

- (void)perform {
    HRPGLoadingViewController *sourceController = (HRPGLoadingViewController*) self.sourceViewController;
    UIViewController *destController = self.destinationViewController;
    
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window insertSubview:destController.view belowSubview:sourceController.view];
    
    for (int y = 0; y < sourceController.lineCount; y++) {
        for (int x = 0; x < 16; x++) {
            UIView *square = sourceController.squares[y][x];
            [UIView animateWithDuration:0.2 delay:0.02*y options:UIViewAnimationOptionCurveEaseIn animations:^() {
                square.transform = CGAffineTransformMakeScale(0.1, 0.1);
                square.alpha = 0;
            }completion:nil];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.3) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^() {
            sourceController.logo.alpha = 0;
        }completion:nil];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.02*sourceController.lineCount+0.2) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [sourceController presentViewController:destController animated:NO completion:NULL];
    });
}

@end
