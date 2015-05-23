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
        welcomePage.desc = NSLocalizedString(@"Welcome to Habitica, a habit-tracker which treats your tasks like a game! Achieve your goals in real-life, then level up to unlock new in-game features.", nil);
        welcomePage.titleFont = titleFont;
        welcomePage.descFont = font;
        welcomePage.titlePositionY = titleY;
        welcomePage.descPositionY = descY;
        welcomePage.titleIconView = avatarImageView;
        welcomePage.titleIconPositionY = screenRect.size.height/3-45;
        
        EAIntroPage *habitPage = [EAIntroPage page];
        habitPage.title = NSLocalizedString(@"Habits", nil);
        habitPage.desc = NSLocalizedString(@"1. Track your habits many times a day!\n2. Good habits give you gold and experience.\n3. Bad habits reduce your health!", nil);
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
        dailyPage.desc = NSLocalizedString(@"1. Dailies are tasks that repeat once a day!\n2. Check them off every day for gold and experience.\n3. BE CAREFUL: If you skip a Daily, your avatar will lose health!", nil);
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
        todoPage.desc = NSLocalizedString(@"1. To-Dos are your To-Do list!\n2. Check them off for gold and experience.\n3. Tap and HOLD to edit!.", nil);

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
        rewardPage.desc = NSLocalizedString(@"1. Use your gold to buy Rewards!\n2. In-game Rewards include equipment.\n3. Set Custom Rewards yourself!", nil);
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
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian
                                           components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                           fromDate:today];
    weekdayComponents.hour = 19;
    NSDate *date = [gregorian dateFromComponents:weekdayComponents];
    [defaults setValue:date forKey:@"dailyReminderTime"];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.repeatInterval = NSDayCalendarUnit;
    localNotification.alertBody = NSLocalizedString(@"Don't forget to check off your Dailies!", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [self removeFromSuperview];
}

@end
