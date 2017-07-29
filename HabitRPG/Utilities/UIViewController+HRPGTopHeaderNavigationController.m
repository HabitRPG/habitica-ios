//
//  UIViewController+HRPGTopHeaderNavigationController.m
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "HRPGTopHeaderNavigationController.h"

@implementation UIViewController (HRPGTopHeaderNavigationController)

- (HRPGTopHeaderNavigationController *)hrpgTopHeaderNavigationController {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        return (HRPGTopHeaderNavigationController *)self.navigationController;
    }
    return nil;
}

@end
