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
#import "CRToast.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/Analytics.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import "Reminder.h"
#import "Amplitude.h"
#import "HRPGLoadingViewController.h"

@interface HRPGAppDelegate ()

@property NSString *notifiedTaskID;

@end

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Crash reports
    [Fabric with:@[ CrashlyticsKit ]];

    // Google Analytics
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];

    [[Amplitude instance] initializeApiKey:@"e8d4c24b3d6ef3ee73eeba715023dd43"];

    // Notifications
    CRToastInteractionResponder *blankResponder = [CRToastInteractionResponder
        interactionResponderWithInteractionType:CRToastInteractionTypeAll
                           automaticallyDismiss:YES
                                          block:^(CRToastInteractionType interactionType){
                                          }];
    [CRToastManager setDefaultOptions:@{
        kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
        kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
        kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
        kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
        kCRToastTimeIntervalKey : @(1.0),
        kCRToastAnimationInTimeIntervalKey : @(0.2),
        kCRToastAnimationOutTimeIntervalKey : @(0.2),
        kCRToastFontKey : [UIFont systemFontOfSize:17],
        kCRToastInteractionRespondersKey : @[ blankResponder ]
    }];

    [self configureNotifications];

    [self cleanAndRefresh:application];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];

        NSDate *oldDate = [NSDate date];
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:oldDate];
        comps.hour = 19;
        comps.minute = 00;
        NSDate *newDate = [calendar dateFromComponents:comps];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dailyReminderActive"];
        [[NSUserDefaults standardUserDefaults] setValue:newDate forKey:@"dailyReminderTime"];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = newDate;
        localNotification.repeatInterval = NSDayCalendarUnit;
        localNotification.alertBody =
            NSLocalizedString(@"Remember to check off your Dailies!", nil);
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }

    UILocalNotification *notification =
        [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        [self displayTaskWithId:[notification.userInfo valueForKey:@"taskID"]
                       fromType:[notification.userInfo valueForKey:@"taskType"]];
    }

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self cleanAndRefresh:application];
}

- (void)cleanAndRefresh:(UIApplication *)application {
    // Update Content if it wasn't updated in the last week.
    NSDate *lastContentFetch =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"lastContentFetch"];
    if (lastContentFetch == nil || [lastContentFetch timeIntervalSinceNow] < -604800) {
        [self.sharedManager fetchContent:^() {
        }
            onError:^(){
            }];
    }
    NSArray *scheduledNotifications =
        [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;

    NSDate *lastReminderSchedule =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReminderSchedule"];
    if (lastReminderSchedule == nil || [lastReminderSchedule timeIntervalSinceNow] < -259200) {
        // Reschedule every 3 days
        [self rescheduleTaskReminders];
    }

    User *user = [self.sharedManager getUser];
    if (user) {
        [self.sharedManager fetchUser:^() {
        }
            onError:^(){
            }];
    }
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
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

- (void)application:(UIApplication *)application
    performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
               completionHandler:(void (^)(BOOL))completionHandler {
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
        UINavigationController *displayedNavigationController =
            tabBarController.selectedViewController;
        UIViewController *displayedTableViewController =
            displayedNavigationController.topViewController;
        [displayedTableViewController performSegueWithIdentifier:@"FormSegue"
                                                          sender:displayedTableViewController];
    }
    completionHandler(YES);
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        NSArray *components = [uniqueIdentifier componentsSeparatedByString:@"."];
        NSString *taskType = components[4];
        NSString *taskID = components[5];
        [self displayTaskWithId:taskID fromType:taskType];
    }
    return YES;
}

- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
          forLocalNotification:(UILocalNotification *)notification
             completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:@"completeAction"]) {
        [self completeTaskWithId:[notification.userInfo valueForKey:@"taskID"]];
    }
}

- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        [self displayTaskWithId:[notification.userInfo valueForKey:@"taskID"]
                       fromType:[notification.userInfo valueForKey:@"taskType"]];
        return;
    }

    self.notifiedTaskID = [notification.userInfo valueForKey:@"taskID"];
    if (self.notifiedTaskID) {
        UIAlertView *message =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reminder", nil)
                                       message:notification.alertBody
                                      delegate:self
                             cancelButtonTitle:NSLocalizedString(@"Close", nil)
                             otherButtonTitles:NSLocalizedString(@"Complete", nil), nil];
        message.delegate = self;
        [message show];
    }
}

- (void)rescheduleTaskReminders {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    for (UILocalNotification *reminder in [sharedApplication scheduledLocalNotifications]) {
        if ([reminder.userInfo objectForKey:@"ID"] != nil) {
            [sharedApplication cancelLocalNotification:reminder];
        }
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Task"
                    inManagedObjectContext:[self.sharedManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"reminders.@count != 0"]];
    NSError *error;
    NSArray *tasks = [[self.sharedManager getManagedObjectContext] executeFetchRequest:fetchRequest
                                                                                 error:&error];

    for (int day = 0; day < 6; day++) {
        for (Task *task in tasks) {
            NSDate *checkedDate = [NSDate dateWithTimeIntervalSinceNow:(day * 86400)];
            if ([task.type isEqualToString:@"daily"] && ![task dueOnDate:checkedDate]) {
                continue;
            }
            for (Reminder *reminder in task.reminders) {
                [reminder scheduleForDay:checkedDate];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReminderSchedule"];
}

- (void)configureNotifications {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;

        UIMutableUserNotificationAction *completeAction =
            [[UIMutableUserNotificationAction alloc] init];
        completeAction.identifier = @"completeAction";
        completeAction.title = NSLocalizedString(@"Complete", nil);
        completeAction.activationMode = UIUserNotificationActivationModeBackground;
        completeAction.destructive = NO;
        completeAction.authenticationRequired = NO;
        UIMutableUserNotificationCategory *completeCategory =
            [[UIMutableUserNotificationCategory alloc] init];
        completeCategory.identifier = @"completeCategory";
        [completeCategory setActions:@[ completeAction ]
                          forContext:UIUserNotificationActionContextDefault];

        UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:types
                                              categories:[NSSet setWithObject:completeCategory]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

- (void)completeTaskWithId:(NSString *)taskID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Task"
                    inManagedObjectContext:[self.sharedManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id = %@", taskID]];
    [fetchRequest
        setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] ]];

    NSError *error;
    NSArray *fetchedObjects =
        [[self.sharedManager getManagedObjectContext] executeFetchRequest:fetchRequest
                                                                    error:&error];
    if (fetchedObjects != nil && fetchedObjects.count == 1) {
        Task *task = [fetchedObjects objectAtIndex:0];
        if (![task.completed boolValue]) {
            [self.sharedManager upDownTask:task
                direction:@"up"
                onSuccess:^(NSArray *valuesArray) {
                    return;
                }
                onError:^() {
                    return;
                }];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self completeTaskWithId:self.notifiedTaskID];
    }
}

- (void)displayTaskWithId:(NSString *)taskID fromType:(nullable NSString *)taskType {
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
        UINavigationController *displayedNavigationController =
            tabBarController.selectedViewController;
        HRPGTableViewController *displayedTableViewController =
            (HRPGTableViewController *)displayedNavigationController.topViewController;
        if ([displayedNavigationController
                respondsToSelector:@selector(setScrollToTaskAfterLoading:)]) {
            displayedTableViewController.scrollToTaskAfterLoading = taskID;
        }
    } else if ([self.window.rootViewController isKindOfClass:[HRPGLoadingViewController class]]) {
        HRPGLoadingViewController *loadingViewController =
            (HRPGLoadingViewController *)self.window.rootViewController;
        loadingViewController.loadingFinishedAction = ^() {
            [self displayTaskWithId:taskID fromType:taskType];
        };
    }
}

@end
