//
//  HRPGTabBarController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGTabBarController.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "User.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "PDKeychainBindings.h"
#import "EAIntroView.h"
#import "EAIntroPage.h"
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
    [swipe setNumberOfTouchesRequired:1];
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

- (void)displayIntro {
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *sharedManager = appdelegate.sharedManager;
    User *user = [sharedManager getUser];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-20, 0, 90, 90)];
    [user setAvatarOnImageView:avatarImageView withPetMount:NO onlyHead:NO useForce:NO];
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:19];
    UIFont *font = [UIFont systemFontOfSize:14];
    CGFloat titleY = (self.view.bounds.size.height/3);
    CGFloat descY = titleY - 20;
    
    EAIntroPage *welcomePage = [EAIntroPage page];
    welcomePage.title = NSLocalizedString(@"Welcome", nil);
    welcomePage.desc = NSLocalizedString(@"Welcome to HabitRPG, a habit-tracker which treats your tasks like a Role Playing Game. ", nil);
    welcomePage.titleFont = titleFont;
    welcomePage.descFont = font;
    welcomePage.titlePositionY = titleY;
    welcomePage.descPositionY = descY;
    welcomePage.titleIconView = avatarImageView;
    welcomePage.titleIconPositionY = self.view.bounds.size.height/3-45;
    
    EAIntroPage *habitPage = [EAIntroPage page];
    habitPage.title = NSLocalizedString(@"Habits", nil);
    habitPage.desc = NSLocalizedString(@"Habits are tasks that you constantly track. They can be given plus or minus values, allowing you to gain experience and gold for good habits or lose health for bad ones.", nil);
    habitPage.titleFont = titleFont;
    habitPage.descFont = font;
    habitPage.titlePositionY = titleY;
    habitPage.descPositionY = descY;
    UIImageView *habitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-40, self.view.bounds.size.height/2)];
    habitImageView.contentMode = UIViewContentModeScaleAspectFit;
    habitImageView.image = [UIImage imageNamed:@"HabitIntro"];
    habitPage.titleIconView = habitImageView;
    
    EAIntroPage *dailyPage = [EAIntroPage page];
    dailyPage.title = NSLocalizedString(@"Dailies", nil);
    dailyPage.desc = NSLocalizedString(@"Dailies are tasks that you want to complete once a day. Checking off a daily reaps experience and gold. Failing to check off your daily before the day resets results in a loss of health.", nil);
    dailyPage.titleFont = titleFont;
    dailyPage.descFont = font;
    dailyPage.titlePositionY = titleY;
    dailyPage.descPositionY = descY;
    UIImageView *dailyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-40, self.view.bounds.size.height/2)];
    dailyImageView.contentMode = UIViewContentModeScaleAspectFit;
    dailyImageView.image = [UIImage imageNamed:@"DailyIntro"];
    dailyPage.titleIconView = dailyImageView;
    
    EAIntroPage *todoPage = [EAIntroPage page];
    todoPage.title = NSLocalizedString(@"To-Dos", nil);
    todoPage.desc = NSLocalizedString(@"To-Dos are one-off tasks that you can get to eventually. While it is possible to set a date on a to-do, they are not required. To-Dos make for a quick and easy way to gain experience.", nil);
    todoPage.titleFont = titleFont;
    todoPage.descFont = font;
    todoPage.titlePositionY = titleY;
    todoPage.descPositionY = descY;
    UIImageView *todoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-40, self.view.bounds.size.height/2)];
    todoImageView.contentMode = UIViewContentModeScaleAspectFit;
    todoImageView.image = [UIImage imageNamed:@"TodoIntro"];
    todoPage.titleIconView = todoImageView;
    
    EAIntroPage *rewardPage = [EAIntroPage page];
    rewardPage.title = NSLocalizedString(@"Rewards", nil);
    rewardPage.desc = NSLocalizedString(@"All that gold you earned will allow you to reward yourself with either custom or in-game prizes. Buy them liberally – rewarding yourself is integral in forming good habits.", nil);
    rewardPage.titleFont = titleFont;
    rewardPage.descFont = font;
    rewardPage.titlePositionY = titleY;
    rewardPage.descPositionY = descY;
    UIImageView *rewardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-40, self.view.bounds.size.height/2)];
    rewardImageView.contentMode = UIViewContentModeScaleAspectFit;
    rewardImageView.image = [UIImage imageNamed:@"RewardIntro"];
    rewardPage.titleIconView = rewardImageView;
    
    EAIntroView *introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[welcomePage, habitPage, dailyPage, todoPage, rewardPage]];
    introView.bgImage = [UIImage imageNamed:@"IntroBG"];
    [introView setDelegate:self];
    [introView showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish:(EAIntroView *)introView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"displayedIntro"];
}

@end
