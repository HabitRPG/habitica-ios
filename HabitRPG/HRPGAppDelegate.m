//
//  HRPGAppDelegate.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGAppDelegate.h"
#import "HRPGTableViewController.h"
#import "HRPGTabBarController.h"
#import "HRPGTableViewController.h"
#import "CRToast.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <CargoBay.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/Analytics.h>
#import <CoreSpotlight/CoreSpotlight.h>

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Crash reports
    [Fabric with:@[CrashlyticsKit]];

    //Google Analytics
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    
    //Notifications
    CRToastInteractionResponder *blankResponder = [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeAll automaticallyDismiss:YES block:^(CRToastInteractionType interactionType){
    }];
    [CRToastManager setDefaultOptions:@{kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                        kCRToastNotificationPresentationTypeKey: @(CRToastPresentationTypeCover),
                                        kCRToastTimeIntervalKey: @(2.0),
                                        kCRToastAnimationInTimeIntervalKey : @(0.7),
                                        kCRToastAnimationOutTimeIntervalKey : @(0.7),
                                        kCRToastFontKey : [UIFont systemFontOfSize:17],
                                        kCRToastInteractionRespondersKey : @[blankResponder]
                                        }];

    [self cleanAndRefresh:application];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];
         
         NSDate *oldDate = [NSDate date];
         unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
         NSCalendar *calendar = [NSCalendar currentCalendar];
         NSDateComponents *comps = [calendar components:unitFlags fromDate:oldDate];
         comps.hour   = 19;
         comps.minute = 00;
         NSDate *newDate = [calendar dateFromComponents:comps];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dailyReminderActive"];
         [[NSUserDefaults standardUserDefaults] setValue:newDate forKey:@"dailyReminderTime"];
         [[UIApplication sharedApplication] cancelAllLocalNotifications];
         UILocalNotification *localNotification = [[UILocalNotification alloc] init];
         localNotification.fireDate = newDate;
         localNotification.repeatInterval = NSDayCalendarUnit;
         localNotification.alertBody = NSLocalizedString(@"Remember to check off your Dailies!", nil);
         localNotification.soundName = UILocalNotificationDefaultSoundName;
         localNotification.timeZone = [NSTimeZone defaultTimeZone];
         [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self cleanAndRefresh:application];
}

- (void)cleanAndRefresh:(UIApplication *)application {
    //Update Content if it wasn't updated in the last week.
    NSDate *lastContentFetch = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastContentFetch"];
    if (lastContentFetch == nil || [lastContentFetch timeIntervalSinceNow] < -604800) {
        [self.sharedManager fetchContent:^() {
        }                    onError:^() {
        }];
    }
    NSArray *scheduledNotifications = [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;
    User *user = [self.sharedManager getUser];
    if (user) {
        [self.sharedManager fetchUser:^() {} onError:^() {}];
    }
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[HRPGManager alloc] init];
        [_sharedManager loadObjectManager:nil];
    }
    return _sharedManager;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    id presentedController = self.window.rootViewController.presentedViewController;
    if ([presentedController isKindOfClass:[HRPGTabBarController class]]) {
        HRPGTabBarController *tabBarController = (HRPGTabBarController *)presentedController;
        if ([shortcutItem.type isEqualToString:@"com.habitrpg.habitica.ios.newhabit"]) {
            [tabBarController setSelectedIndex:0];
        } else if ([shortcutItem.type isEqualToString:@"com.habitrpg.habitica.ios.newdaily"]) {
            [tabBarController setSelectedIndex:1];
        } else if ([shortcutItem.type isEqualToString:@"com.habitrpg.habitica.ios.newtodo"]) {
            [tabBarController setSelectedIndex:2];
        } else {
            return;
        }
        UINavigationController *displayedNavigationController = tabBarController.selectedViewController;
        UIViewController *displayedTableViewController = displayedNavigationController.topViewController;
        [displayedTableViewController performSegueWithIdentifier:@"FormSegue" sender:displayedTableViewController];
    }
    completionHandler(YES);

}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        NSArray *components = [uniqueIdentifier componentsSeparatedByString:@"."];
        NSString *taskType = components[4];
        NSString *taskID = components[5];
        id presentedController = self.window.rootViewController.presentedViewController;
        if ([presentedController isKindOfClass:[HRPGTabBarController class]]) {
            HRPGTabBarController *tabBarController = (HRPGTabBarController *)presentedController;
            if ([taskType isEqualToString:@"habit"]) {
                [tabBarController setSelectedIndex:0];
            } else if ([taskType isEqualToString:@"daily"]) {
                [tabBarController setSelectedIndex:1];
            } else if ([taskType isEqualToString:@"todo"]) {
                [tabBarController setSelectedIndex:2];
            }
            UINavigationController *displayedNavigationController = tabBarController.selectedViewController;
            HRPGTableViewController *displayedTableViewController = (HRPGTableViewController *)displayedNavigationController.topViewController;
            [displayedTableViewController scrollToTaskWithId:taskID];
        }

    }
    return YES;
}

@end
