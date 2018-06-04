//
//  HRPGAppDelegate.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGAppDelegate.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import "Amplitude.h"
#import "HRPGMaintenanceViewController.h"
#import "HRPGInboxChatViewController.h"
#import "UIColor+Habitica.h"
#import <Keys/HabiticaKeys.h>
#import "AppAuth.h"
#import "Habitica-Swift.h"

@interface HRPGAppDelegate ()


@end

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.swiftAppDelegate = [[HabiticaAppDelegate alloc] init];
    
    [self.swiftAppDelegate setupLogging];
    [self.swiftAppDelegate setupAnalytics];
    [self.swiftAppDelegate setupPopups];
    [self.swiftAppDelegate setupPurchaseHandling];
    [self.swiftAppDelegate setupNetworkClient];
    [self.swiftAppDelegate setupDatabase];
    [self.swiftAppDelegate setupTheme];
    
    [self configureNotifications:application];

    [self.swiftAppDelegate handleInitialLaunch];

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
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self cleanAndRefresh:application];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.swiftAppDelegate setupUserManager];
}

- (void)cleanAndRefresh:(UIApplication *)application {
    NSArray *scheduledNotifications =
        [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;

    [self.swiftAppDelegate retrieveContent];

    [self.swiftAppDelegate handleMaintenanceScreen];
    [[[ConfigRepository alloc] init] fetchremoteConfig];
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
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
    if ([presentedController isKindOfClass:[MainTabBarController class]]) {
        MainTabBarController *tabBarController = (MainTabBarController *)presentedController;
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
        [self.swiftAppDelegate acceptQuestInvitation:^(BOOL success) {
            if (!success) {
                [self displayLocalNotificationWithMessage:NSLocalizedString(@"There was an error accepting the quest invitation", nil) withApplication:application];
            }
            completionHandler();
        }];
    } else if ([identifier isEqualToString:@"rejectAction"]) {
        [self.swiftAppDelegate rejectQuestInvitation:^(BOOL success) {
            if (!success) {
                [self displayLocalNotificationWithMessage:NSLocalizedString(@"There was an error rejecting the quest invitation", nil) withApplication:application];
            }
            completionHandler();
        }];
    } else if ([identifier isEqualToString:@"replyAction"]) {
        [self.swiftAppDelegate sendPrivateMessageToUserID:userInfo[@"replyTo"]
                                                  message:responseInfo[UIUserNotificationActionResponseTypedTextKey]
                                                completed:^(BOOL success) {
                                                    if (!success) {
                                                        [self displayLocalNotificationWithMessage:NSLocalizedString(@"Your message could not be sent.", nil) withApplication:application];
                                                    }
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

    HabiticaAlertController *alertController = [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Reminder", nil) message:notification.alertBody];
    [alertController addActionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleDefault isMainAction:NO closeOnTap:true handler:nil];
    [alertController addActionWithTitle:NSLocalizedString(@"Complete", nil) style:UIAlertActionStyleDefault isMainAction:YES closeOnTap:true handler:^(UIButton * _Nonnull button) {
        [self completeTaskWithId:[notification.userInfo valueForKey:@"taskID"] completionHandler:nil];
    }];
    [alertController show];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        [self handlePushNotification:userInfo];
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self displayPushNotificationInApp:userInfo];
    }
}

- (void)handlePushNotification:(NSDictionary *)userInfo {
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:userInfo[@"identifier"] forKey:@"identifier"];
    [[Amplitude instance] logEvent:@"open notification" withEventProperties:eventProperties];
    
    UINavigationController *displayedNavigationController = [self displayTabAtIndex:4];
    if (displayedNavigationController) {
        if ([userInfo[@"identifier"] isEqualToString:@"newPM"] || [userInfo[@"identifier"] isEqualToString:@"giftedGems"] || [userInfo[@"identifier"] isEqualToString:@"giftedSubscription"]) {
            HRPGInboxChatViewController *inboxChatViewController = (HRPGInboxChatViewController *)[self loadViewController:@"InboxChatViewController" fromStoryboard:@"Social"];
            inboxChatViewController.userID = userInfo[@"replyTo"];
            [displayedNavigationController pushViewController:inboxChatViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"invitedParty"] || [userInfo[@"identifier"] isEqualToString:@"questStarted"]) {
            PartyViewController *partyViewController = (PartyViewController *)[self loadViewController:@"PartyViewController" fromStoryboard:@"Social"];
            [displayedNavigationController pushViewController:partyViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"invitedGuild"]) {
            SplitSocialViewController *guildViewController = (SplitSocialViewController *)[self loadViewController:@"GroupTableViewController" fromStoryboard:@"Social"];
            guildViewController.groupID = userInfo[@"groupID"];
            [displayedNavigationController pushViewController:guildViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"questInvitation"]) {
            QuestDetailViewController *questDetailViewController = (QuestDetailViewController *)[self loadViewController:@"QuestDetailViewController" fromStoryboard:@"Social"];
            [displayedNavigationController pushViewController:questDetailViewController animated:YES];
        }
    } else if ([self.window.rootViewController isKindOfClass:[LoadingViewController class]]) {
        LoadingViewController *loadingViewController =
        (LoadingViewController *)self.window.rootViewController;
        __weak HRPGAppDelegate *weakSelf = self;
        loadingViewController.loadingFinishedAction = ^() {
            [weakSelf handlePushNotification:userInfo];
        };
    }
}

- (void)configureNotifications:(UIApplication *)application {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;

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
    [self.swiftAppDelegate scoreTask:taskID direction:@"up" completed: ^() {
        if (completionHandler) {
            completionHandler();
        };
    }];
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
        TaskTableViewController *displayedTableViewController =
            (TaskTableViewController *)displayedNavigationController.topViewController;
        if ([displayedNavigationController
                respondsToSelector:@selector(setScrollToTaskAfterLoading:)]) {
            displayedTableViewController.scrollToTaskAfterLoading = taskID;
        }
    } else if ([self.window.rootViewController isKindOfClass:[LoadingViewController class]]) {
        LoadingViewController *loadingViewController =
            (LoadingViewController *)self.window.rootViewController;
        __weak HRPGAppDelegate *weakSelf = self;
        loadingViewController.loadingFinishedAction = ^() {
            [weakSelf displayTaskWithId:taskID fromType:taskType];
        };
    }
}

- (UINavigationController *)displayTabAtIndex:(int)index {
    id presentedController = self.window.rootViewController.presentedViewController;
    if ([presentedController isKindOfClass:[MainTabBarController class]]) {
        MainTabBarController *tabBarController = (MainTabBarController *)presentedController;
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
    [ToastManager showWithText:text color:ToastColorPurple];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if (AuthenticationManager.shared.hasAuthentication) {
        [self.swiftAppDelegate retrieveTasks:^(BOOL completed) {
            if (completed) {
                completionHandler(UIBackgroundFetchResultNewData);
            } else {
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    }
}

@end
