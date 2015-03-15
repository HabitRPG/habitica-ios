//
//  HRPGNavigationController.m
//  Habitica
//
//  Created by viirus on 07/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGNavigationController.h"

@interface HRPGNavigationController ()

@end

@implementation HRPGNavigationController



- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    if ([self.sourceViewController canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender])
        return self.sourceViewController;
    for(UIViewController *vc in self.viewControllers){
        // Always use -canPerformUnwindSegueAction:fromViewController:withSender:
        // to determine if a view controller wants to handle an unwind action.
        if ([vc canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender])
            return vc;
    }
    
    
    return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

@end
