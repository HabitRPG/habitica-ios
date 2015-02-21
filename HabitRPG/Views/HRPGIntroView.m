//
//  HRPGIntroView.m
//  Habitica
//
//  Created by viirus on 21.02.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGIntroView.h"
#import <EAIntroView/EAIntroView.h>
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@interface HRPGIntroView ()
@property EAIntroView *introView;
@end

@implementation HRPGIntroView

- (id)init {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        HRPGManager *sharedManager = appdelegate.sharedManager;
        User *user = [sharedManager getUser];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-20, 0, 90, 90)];
        [user setAvatarOnImageView:avatarImageView withPetMount:NO onlyHead:NO useForce:NO];
        
        UIFont *titleFont = [UIFont boldSystemFontOfSize:19];
        UIFont *font = [UIFont systemFontOfSize:14];
        CGFloat titleY = (screenRect.size.height/3);
        CGFloat descY = titleY - 20;
        
        EAIntroPage *welcomePage = [EAIntroPage page];
        welcomePage.title = NSLocalizedString(@"Welcome", nil);
        welcomePage.desc = NSLocalizedString(@"Welcome to HabitRPG, a habit-tracker which treats your tasks like a Role Playing Game. ", nil);
        welcomePage.titleFont = titleFont;
        welcomePage.descFont = font;
        welcomePage.titlePositionY = titleY;
        welcomePage.descPositionY = descY;
        welcomePage.titleIconView = avatarImageView;
        welcomePage.titleIconPositionY = screenRect.size.height/3-45;
        
        EAIntroPage *habitPage = [EAIntroPage page];
        habitPage.title = NSLocalizedString(@"Habits", nil);
        habitPage.desc = NSLocalizedString(@"Habits are tasks that you constantly track. They can be given plus or minus values, allowing you to gain experience and gold for good habits or lose health for bad ones.", nil);
        habitPage.titleFont = titleFont;
        habitPage.descFont = font;
        habitPage.titlePositionY = titleY;
        habitPage.descPositionY = descY;
        UIImageView *habitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width-40, screenRect.size.height/2)];
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
        UIImageView *dailyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width-40, screenRect.size.height/2)];
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
        UIImageView *todoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width-40, screenRect.size.height/2)];
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
        UIImageView *rewardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width-40, screenRect.size.height/2)];
        rewardImageView.contentMode = UIViewContentModeScaleAspectFit;
        rewardImageView.image = [UIImage imageNamed:@"RewardIntro"];
        rewardPage.titleIconView = rewardImageView;
        
        self.introView = [[EAIntroView alloc] initWithFrame:screenRect andPages:@[welcomePage, habitPage, dailyPage, todoPage, rewardPage]];
        self.introView.bgImage = [UIImage imageNamed:@"IntroBG"];
        [self.introView setDelegate:self];

    }
    return self;
}

- (void)displayIntro {
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview: self];
    [self.introView showInView:self animateDuration:0.0];
}

- (void)introDidFinish:(EAIntroView *)introView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"displayedIntro"];
    [self removeFromSuperview];
}

@end
