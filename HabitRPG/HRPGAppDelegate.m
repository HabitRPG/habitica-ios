//
//  HRPGAppDelegate.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGAppDelegate.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <Google/Analytics.h>
#import "AFNetworking.h"
#import "Amplitude.h"
#import "CRToast.h"
#import "HRPGLoadingViewController.h"
#import "HRPGMaintenanceViewController.h"
#import "HRPGTabBarController.h"
#import "HRPGTableViewController.h"
#import "Reminder.h"
#import "HRPGInboxChatViewController.h"
#import "HRPGPartyTableViewController.h"
#import "HRPGQuestDetailViewController.h"
#import "UIColor+Habitica.h"
#import <Keys/HabiticaKeys.h>

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

    HabiticaKeys *keys = [[HabiticaKeys alloc] init];
    
    [[Amplitude instance] initializeApiKey:keys.amplitudeApiKey];

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
        kCRToastTimeIntervalKey : @(1.5),
        kCRToastAnimationInTimeIntervalKey : @(0.25),
        kCRToastAnimationOutTimeIntervalKey : @(0.25),
        kCRToastFontKey : [UIFont systemFontOfSize:17],
        kCRToastInteractionRespondersKey : @[ blankResponder ]
    }];
    
    [[UIView appearanceWhenContainedIn:[UIAlertView class], nil] setTintColor:[UIColor purple400]];
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor purple400]];

    [self configureNotifications:application];

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
        launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        [self displayTaskWithId:[notification.userInfo valueForKey:@"taskID"]
                       fromType:[notification.userInfo valueForKey:@"taskType"]];
    }

    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo) {
        [self handlePushNotification:userInfo];
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
    NSString *lastContentFetchVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastContentFetchVersion"];
    NSString *currentBuildNumber = [[NSBundle mainBundle]
                                    objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    if (lastContentFetch == nil || [lastContentFetch timeIntervalSinceNow] < -604800 || ![lastContentFetchVersion isEqualToString:currentBuildNumber]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentBuildNumber forKey:@"lastContentFetchVersion"];
        [self.sharedManager fetchContent:nil onError:nil];
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
        [self.sharedManager fetchUser:nil onError:nil];
    }

    [self checkMaintenanceScreen];
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
    
    if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }
    
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
        [self completeTaskWithId:[notification.userInfo valueForKey:@"taskID"] completionHandler:completionHandler];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [self application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:@{} completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:@"acceptAction"]) {
        [self.sharedManager acceptQuest:[self.sharedManager getUser].partyID onSuccess:^() {
            completionHandler();
        } onError:^(NSString *errorMessage) {
            [self displayLocalNotificationWithMessage:errorMessage withApplication:application];
            completionHandler();
        }];
    } else if ([identifier isEqualToString:@"rejectAction"]) {
        [self.sharedManager rejectQuest:[self.sharedManager getUser].partyID onSuccess:^() {
            completionHandler();
        } onError:^(NSString *errorMessage) {
            [self displayLocalNotificationWithMessage:errorMessage withApplication:application];
            completionHandler();
        }];
    } else if ([identifier isEqualToString:@"replyAction"]) {
        [self.sharedManager privateMessage:responseInfo[UIUserNotificationActionResponseTypedTextKey] toUserWithID:userInfo[@"replyTo"] onSuccess:^() {
            completionHandler();
        } onError:^() {
            [self displayLocalNotificationWithMessage:NSLocalizedString(@"Your message could not be sent.", nil) withApplication:application];
            completionHandler();
        }];
    }
}

- (void) displayLocalNotificationWithMessage:(NSString *)message withApplication:(UIApplication *)application {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertBody:[NSString stringWithFormat:NSLocalizedString(@"There was an error with your request: %@", nil), message]];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];

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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        [self handlePushNotification:userInfo];
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self displayPushNotificationInApp:userInfo];
    }
}

- (void)handlePushNotification:(NSDictionary *)userInfo {
    UINavigationController *displayedNavigationController = [self displayTabAtIndex:4];
    if (displayedNavigationController) {
        if ([userInfo[@"identifier"] isEqualToString:@"newPM"] || [userInfo[@"identifier"] isEqualToString:@"giftedGems"] || [userInfo[@"identifier"] isEqualToString:@"giftedSubscription"]) {
            HRPGInboxChatViewController *inboxChatViewController = (HRPGInboxChatViewController *)[self loadViewController:@"InboxChatViewController" fromStoryboard:@"Social"];
            inboxChatViewController.userID = userInfo[@"replyTo"];
            [displayedNavigationController pushViewController:inboxChatViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"invitedParty"] || [userInfo[@"identifier"] isEqualToString:@"questStarted"]) {
            HRPGPartyTableViewController *partyViewController = (HRPGPartyTableViewController *)[self loadViewController:@"PartyViewController" fromStoryboard:@"Social"];
            [displayedNavigationController pushViewController:partyViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"invitedGuild"]) {
            HRPGGroupTableViewController *guildViewController = (HRPGGroupTableViewController *)[self loadViewController:@"GroupTableViewController" fromStoryboard:@"Social"];
            guildViewController.groupID = userInfo[@"groupID"];
            [displayedNavigationController pushViewController:guildViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"questInvitation"]) {
            HRPGQuestDetailViewController *questDetailViewController = (HRPGQuestDetailViewController *)[self loadViewController:@"QuestDetailViewController" fromStoryboard:@"Social"];
            [displayedNavigationController pushViewController:questDetailViewController animated:YES];
        }
    } else if ([self.window.rootViewController isKindOfClass:[HRPGLoadingViewController class]]) {
        HRPGLoadingViewController *loadingViewController =
        (HRPGLoadingViewController *)self.window.rootViewController;
        __weak HRPGAppDelegate *weakSelf = self;
        loadingViewController.loadingFinishedAction = ^() {
            [weakSelf handlePushNotification:userInfo];
        };
    }
}


- (void)rescheduleTaskReminders {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    for (UILocalNotification *reminder in [sharedApplication scheduledLocalNotifications]) {
        if (reminder.userInfo[@"ID"] != nil) {
            [sharedApplication cancelLocalNotification:reminder];
        }
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Task"
                    inManagedObjectContext:[self.sharedManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest
        setPredicate:[NSPredicate predicateWithFormat:@"reminders.@count != 0 && (type == 'daily' "
                                                      @"|| (type == 'todo' && completed == NO))"]];
    NSError *error;
    NSArray *tasks = [[self.sharedManager getManagedObjectContext] executeFetchRequest:fetchRequest
                                                                                 error:&error];

    for (Task *task in tasks) {
        for (Reminder *reminder in task.reminders) {
            [reminder scheduleReminders];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReminderSchedule"];
}

- (void)configureNotifications:(UIApplication *)application {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;

        UIMutableUserNotificationAction *completeAction =
            [[UIMutableUserNotificationAction alloc] init];
        completeAction.identifier = @"completeAction";
        completeAction.title = NSLocalizedString(@"Complete", nil);
        completeAction.activationMode = UIUserNotificationActivationModeBackground;
        completeAction.authenticationRequired = NO;
        UIMutableUserNotificationCategory *completeCategory =
            [[UIMutableUserNotificationCategory alloc] init];
        completeCategory.identifier = @"completeCategory";
        [completeCategory setActions:@[ completeAction ]
                          forContext:UIUserNotificationActionContextDefault];

        UIMutableUserNotificationAction *acceptAction =
        [[UIMutableUserNotificationAction alloc] init];
        acceptAction.identifier = @"acceptAction";
        acceptAction.title = NSLocalizedString(@"Accept", nil);
        acceptAction.activationMode = UIUserNotificationActivationModeBackground;
        acceptAction.authenticationRequired = NO;
        UIMutableUserNotificationAction *rejectAction =
        [[UIMutableUserNotificationAction alloc] init];
        rejectAction.identifier = @"rejectAction";
        rejectAction.title = NSLocalizedString(@"Reject", nil);
        rejectAction.activationMode = UIUserNotificationActivationModeBackground;
        rejectAction.destructive = YES;
        rejectAction.authenticationRequired = NO;
        UIMutableUserNotificationCategory *questInviteCategory =
        [[UIMutableUserNotificationCategory alloc] init];
        questInviteCategory.identifier = @"questInvitation";
        [questInviteCategory setActions:@[ acceptAction, rejectAction ]
                          forContext:UIUserNotificationActionContextDefault];
        
        UIMutableUserNotificationAction *replyAction =
        [[UIMutableUserNotificationAction alloc] init];
        replyAction.identifier = @"replyAction";
        replyAction.title = NSLocalizedString(@"Reply", nil);
        replyAction.activationMode = UIUserNotificationActivationModeBackground;
        replyAction.authenticationRequired = NO;
        if ([UIMutableUserNotificationAction instancesRespondToSelector:@selector(setBehavior:)]) {
            replyAction.behavior = UIUserNotificationActionBehaviorTextInput;
        }
        UIMutableUserNotificationCategory *privateMessageCategory =
        [[UIMutableUserNotificationCategory alloc] init];
        privateMessageCategory.identifier = @"newPM";
        [privateMessageCategory setActions:@[ replyAction ]
                          forContext:UIUserNotificationActionContextDefault];
        
        UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:types
                                              categories:[NSSet setWithObjects:completeCategory, questInviteCategory, privateMessageCategory, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"PushNotificationDeviceToken"];
}

- (void)completeTaskWithId:(NSString *)taskID completionHandler:(void (^)())completionHandler {
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
        Task *task = fetchedObjects[0];
        if (![task.completed boolValue]) {
            [self.sharedManager upDownTask:task
                direction:@"up"
                onSuccess:^(NSArray *valuesArray) {
                    if (completionHandler) {
                        completionHandler();
                    };
                }
                onError:^() {
                    if (completionHandler) {
                        completionHandler();
                    };
                }];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self completeTaskWithId:self.notifiedTaskID completionHandler:nil];
    }
}

- (void)displayTaskWithId:(NSString *)taskID fromType:(nullable NSString *)taskType {
    UINavigationController *displayedNavigationController;
    if ([taskType isEqualToString:@"habit"]) {
        displayedNavigationController = [self displayTabAtIndex:0];
    } else if ([taskType isEqualToString:@"daily"]) {
        displayedNavigationController = [self displayTabAtIndex:1];
    } else if ([taskType isEqualToString:@"todo"]) {
        displayedNavigationController = [self displayTabAtIndex:2];
    }
    if (displayedNavigationController) {
        HRPGTableViewController *displayedTableViewController =
            (HRPGTableViewController *)displayedNavigationController.topViewController;
        if ([displayedNavigationController
                respondsToSelector:@selector(setScrollToTaskAfterLoading:)]) {
            displayedTableViewController.scrollToTaskAfterLoading = taskID;
        }
    } else if ([self.window.rootViewController isKindOfClass:[HRPGLoadingViewController class]]) {
        HRPGLoadingViewController *loadingViewController =
            (HRPGLoadingViewController *)self.window.rootViewController;
        __weak HRPGAppDelegate *weakSelf = self;
        loadingViewController.loadingFinishedAction = ^() {
            [weakSelf displayTaskWithId:taskID fromType:taskType];
        };
    }
}

- (void)checkMaintenanceScreen {
    NSURL *url = [NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/endpoint/maintenance-ios.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
        JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSDictionary *data = (NSDictionary *)JSON;
            BOOL activeMaintenance = [data[@"activeMaintenance"] boolValue];
            if (activeMaintenance) {
                [self displayMaintenanceScreen:data isDeprecated:NO];
            } else {
                UIViewController *presentedController =
                    self.window.rootViewController.presentedViewController;
                if ([presentedController.presentedViewController
                        isKindOfClass:[HRPGMaintenanceViewController class]]) {
                    [presentedController.presentedViewController dismissViewControllerAnimated:YES
                                                                                    completion:nil];
                }
                if (data[@"minBuild"]) {
                    NSString *build =
                        [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey];
                    if ([data[@"minBuild"] integerValue] > [build integerValue]) {
                        NSURL *url =
                            [NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/"
                                                 @"mobileApp/endpoint/deprecation-ios.json"];
                        NSURLRequest *request = [NSURLRequest requestWithURL:url];
                        AFJSONRequestOperation *deprecationOperation = [AFJSONRequestOperation
                            JSONRequestOperationWithRequest:request
                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                NSDictionary *data = (NSDictionary *)JSON;
                                [self displayMaintenanceScreen:data isDeprecated:YES];
                            }
                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                      NSError *error, id JSON){
                            }];
                        [deprecationOperation start];
                    }
                }
            }
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        }];
    [operation start];
}

- (void)displayMaintenanceScreen:(NSDictionary *)data isDeprecated:(BOOL)isDeprecated {
    UIViewController *presentedController = self.window.rootViewController.presentedViewController;
    if (![presentedController.presentedViewController
            isKindOfClass:[HRPGMaintenanceViewController class]]) {
        HRPGMaintenanceViewController *maintenanceViewController =
            [[HRPGMaintenanceViewController alloc] init];
        [maintenanceViewController setMaintenanceData:data];
        maintenanceViewController.isDeprecatedApp = isDeprecated;
        [presentedController presentViewController:maintenanceViewController
                                          animated:YES
                                        completion:nil];
    }
}

- (UINavigationController *)displayTabAtIndex:(int)index {
    id presentedController = self.window.rootViewController.presentedViewController;
    if ([presentedController isKindOfClass:[HRPGTabBarController class]]) {
        HRPGTabBarController *tabBarController = (HRPGTabBarController *)presentedController;
        [tabBarController setSelectedIndex:index];
        return tabBarController.selectedViewController;
    } else {
        return nil;
    }
}

- (UIViewController *)loadViewController:(NSString *)name fromStoryboard:(NSString *)storyboardName {
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return [secondStoryBoard instantiateViewControllerWithIdentifier:name];
}

- (void)displayPushNotificationInApp:(NSDictionary *)userInfo {
    NSString *text = userInfo[@"aps"][@"alert"];
    NSDictionary *options = @{
                              kCRToastTextKey : text,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastBackgroundColorKey : [UIColor purple200],
                              kCRToastTimeIntervalKey: @(2.5)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                }];
}

@end
