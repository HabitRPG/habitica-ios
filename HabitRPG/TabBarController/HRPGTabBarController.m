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
#if DEBUG
#import "FLEXManager.h"
#endif


@interface HRPGTabBarController ()

@end

@implementation HRPGTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];

    UITabBarItem *item0 = self.tabBar.items[0];
    item0.image = [factory createImageForIcon:NIKFontAwesomeIconArrowsV];

    UIImage *calendarImage = [factory createImageForIcon:NIKFontAwesomeIconCalendarO];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(calendarImage.size.width, calendarImage.size.height), NO, 0.0f);
    [calendarImage drawInRect:CGRectMake(0, 0, calendarImage.size.width, calendarImage.size.height)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
    CGSize size = [dateString sizeWithAttributes:textAttributes];
    int offset = (calendarImage.size.width - size.width) / 2;
    [dateString drawInRect:CGRectMake(offset + 0.5f, 8, 20, 20) withAttributes:textAttributes];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UITabBarItem *item1 = self.tabBar.items[1];
    item1.image = resultImage;

    UITabBarItem *item2 = self.tabBar.items[2];
    item2.image = [factory createImageForIcon:NIKFontAwesomeIconCheckSquareO];

    UITabBarItem *item3 = self.tabBar.items[3];
    item3.image = [factory createImageForIcon:NIKFontAwesomeIconTrophy];
    
    UITabBarItem *item4 = self.tabBar.items[4];
    item4.image = [factory createImageForIcon:NIKFontAwesomeIconBars]			;

    [self.tabBar setTintColor:[UIColor colorWithRed:0.366 green:0.599 blue:0.014 alpha:1.000]];

    
#if DEBUG
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDebugMenu:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipe setDelaysTouchesBegan:YES];
    [swipe setNumberOfTouchesRequired:3];
    [[self view] addGestureRecognizer:swipe];
#endif
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    UINavigationController *navController = (UINavigationController *) self.selectedViewController;
    if (navController.topViewController.isEditing) {
        [navController.topViewController setEditing:NO animated:YES];
    }
}
#if DEBUG

- (void)showDebugMenu:(UISwipeGestureRecognizer *)swipeRecognizer {
    if (swipeRecognizer.state == UIGestureRecognizerStateRecognized) {
        // This could also live in a handler for a keyboard shortcut, debug menu item, etc.
        [[FLEXManager sharedManager] showExplorer];
    }
}
#endif

@end
