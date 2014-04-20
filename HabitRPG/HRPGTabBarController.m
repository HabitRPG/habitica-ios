//
//  HRPGTabBarController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGTabBarController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface HRPGTabBarController ()

@end

@implementation HRPGTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    
    UITabBarItem *item0 = self.tabBar.items[0];
    item0.image = [factory createImageForIcon:NIKFontAwesomeIconArrowsV];
    
    UITabBarItem *item1 = self.tabBar.items[1];
    item1.image = [factory createImageForIcon:NIKFontAwesomeIconCalendarO];

    UITabBarItem *item2 = self.tabBar.items[2];
    item2.image = [factory createImageForIcon:NIKFontAwesomeIconCheckSquareO];

    UITabBarItem *item3 = self.tabBar.items[3];
    item3.image = [factory createImageForIcon:NIKFontAwesomeIconUser];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    UINavigationController *navController = (UINavigationController*) self.selectedViewController;
    if (navController.topViewController.isEditing) {
        [navController.topViewController setEditing:NO animated:YES];
    }
}

@end
