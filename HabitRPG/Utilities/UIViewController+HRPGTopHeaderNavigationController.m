//
//  UIViewController+HRPGTopHeaderNavigationController.m
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"

@implementation UIViewController (TopHeaderViewController)

- (TopHeaderViewController *)hrpgTopHeaderNavigationController {
    if ([self.navigationController isKindOfClass:[TopHeaderViewController class]]) {
        return (TopHeaderViewController *)self.navigationController;
    }
    return nil;
}

@end
