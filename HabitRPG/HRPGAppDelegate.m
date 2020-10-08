//
//  HRPGAppDelegate.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGAppDelegate.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "HRPGMaintenanceViewController.h"
#import <Keys/HabiticaKeys.h>
#import "AppAuth.h"
#import "Habitica-Swift.h"
#if DEBUG
    #import "SDStatusBarManager.h"
#endif

@interface HRPGAppDelegate ()


@end

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.swiftAppDelegate = [[HabiticaAppDelegate alloc] initWithApplication: application];
    
    [self.swiftAppDelegate handleLaunchArgs];
#if DEBUG
    [[SDStatusBarManager sharedInstance] enableOverrides];
#endif
    
    [self.swiftAppDelegate setupLogging];
    [self.swiftAppDelegate setupAnalytics];
    [self.swiftAppDelegate setupRouter];
    [self.swiftAppDelegate setupPurchaseHandling];
    [self.swiftAppDelegate setupNetworkClient];
    [self.swiftAppDelegate setupTheme];
    [self.swiftAppDelegate setupDatabase];
    [self.swiftAppDelegate setupFirebase];
    
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
    
    UINavigationController *displayedNavigationController = [self displayTabAtIndex:4];

    AuthenticationSettingsViewController *authSettingsViewcontroller = (AuthenticationSettingsViewController *)[self loadViewController:@"AuthenticationSettingsViewController" fromStoryboard:@"Settings"];
    [displayedNavigationController pushViewController:authSettingsViewcontroller animated:YES];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.swiftAppDelegate setupUserManager];
    [self.swiftAppDelegate setupTheme];
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }

    return [RouterHandler.shared handleWithUrl:url];
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
        
    if ([_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }
    
    BOOL wasHandled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    
    if (!wasHandled) {
        return [RouterHandler.shared handleWithUrl:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        NSArray *components = [uniqueIdentifier componentsSeparatedByString:@"."];
        NSString *taskType = components[4];
        NSString *taskID = components[5];
        [self displayTaskWithId:taskID fromType:taskType];
        return YES;
    }
    return [RouterHandler.shared handleWithUserActivity:userActivity];
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

- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
          forLocalNotification:(UILocalNotification *)notification
          completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:@"completeAction"]) {
        [self completeTaskWithId:[notification.userInfo valueForKey:@"taskID"] completionHandler:completionHandler];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)(void))completionHandler {
    [self application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:@{} completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)(void))completionHandler {
    if ([identifier isEqualToString:@"acceptAction"]) {
        [self.swiftAppDelegate acceptQuestInvitation:^(BOOL success) {
            if (!success) {
                [self displayLocalNotificationWithMessage:objcL10n.errorQuestInviteAccept withApplication:application];
            }
            completionHandler();
        }];
    } else if ([identifier isEqualToString:@"rejectAction"]) {
        [self.swiftAppDelegate rejectQuestInvitation:^(BOOL success) {
            if (!success) {
                [self displayLocalNotificationWithMessage:objcL10n.errorQuestInviteReject withApplication:application];
            }
            completionHandler();
        }];
    } else if ([identifier isEqualToString:@"replyAction"]) {
        [self.swiftAppDelegate sendPrivateMessageToUserID:userInfo[@"replyTo"]
                                                  message:responseInfo[UIUserNotificationActionResponseTypedTextKey]
                                                completed:^(BOOL success) {
                                                    if (!success) {
                                                        [self displayLocalNotificationWithMessage:objcL10n.errorReply withApplication:application];
                                                    }
                                                    completionHandler();
                                                }];
    }
}

- (void) displayLocalNotificationWithMessage:(NSString *)message withApplication:(UIApplication *)application {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertBody:[objcL10n errorRequestWithMessage: message]];
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
    [self.swiftAppDelegate displayInAppNotificationWithTaskID:[notification.userInfo valueForKey:@"taskID"] text:notification.alertBody];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        [self handlePushNotification:userInfo];
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if ([userInfo[@"aps"][@"alert"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = userInfo[@"aps"][@"alert"];
            [self.swiftAppDelegate displayNotificationInAppWithTitle:dict[@"title"] text:dict[@"body"]];
        } else {
            [self.swiftAppDelegate displayNotificationInAppWithText:userInfo[@"aps"][@"alert"]];
        }
    }
}

- (void)handlePushNotification:(NSDictionary *)userInfo {
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:userInfo[@"identifier"] forKey:@"identifier"];
    [ObjcHabiticaAnalytics log:@"open notification" withEventProperties:eventProperties];
    
    UINavigationController *displayedNavigationController = [self displayTabAtIndex:4];
    if (displayedNavigationController) {
        if ([userInfo[@"identifier"] isEqualToString:@"newPM"] || [userInfo[@"identifier"] isEqualToString:@"giftedGems"] || [userInfo[@"identifier"] isEqualToString:@"giftedSubscription"]) {
            InboxChatViewController *inboxChatViewController = (InboxChatViewController *)[self loadViewController:@"InboxChatViewController" fromStoryboard:@"Social"];
            inboxChatViewController.userID = userInfo[@"replyTo"];
            [displayedNavigationController pushViewController:inboxChatViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"invitedParty"] || [userInfo[@"identifier"] isEqualToString:@"questStarted"]) {
            [RouterHandler.shared handleWithUrlString:@"/party"];
        } else if ([userInfo[@"identifier"] isEqualToString:@"invitedGuild"]) {
            SplitSocialViewController *guildViewController = (SplitSocialViewController *)[self loadViewController:@"GroupTableViewController" fromStoryboard:@"Social"];
            guildViewController.groupID = userInfo[@"groupID"];
            [displayedNavigationController pushViewController:guildViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"questInvitation"]) {
            QuestDetailViewController *questDetailViewController = (QuestDetailViewController *)[self loadViewController:@"QuestDetailViewController" fromStoryboard:@"Social"];
            [displayedNavigationController pushViewController:questDetailViewController animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"changeUsername"]) {
            AuthenticationSettingsViewController *authSettingsViewcontroller = (AuthenticationSettingsViewController *)[self loadViewController:@"AuthenticationSettingsViewController" fromStoryboard:@"Settings"];
            [displayedNavigationController pushViewController:authSettingsViewcontroller animated:YES];
        } else if ([userInfo[@"identifier"] isEqualToString:@"groupActivity"] || [userInfo[@"identifier"] isEqualToString:@"chatMention"]) {
            if ([userInfo[@"type"] isEqual:@"party"]) {
                [RouterHandler.shared handleWithUrlString:@"/party"];
            } else {
                [RouterHandler.shared handleWithUrlString:[NSString stringWithFormat:@"/groups/guild/%@", userInfo[@"groupID"]]];
            }
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
        completeAction.title = objcL10n.complete;
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
        acceptAction.title = objcL10n.accept;
        acceptAction.activationMode = UIUserNotificationActivationModeBackground;
        acceptAction.authenticationRequired = NO;
        UIMutableUserNotificationAction *rejectAction =
        [[UIMutableUserNotificationAction alloc] init];
        rejectAction.identifier = @"rejectAction";
        rejectAction.title = objcL10n.reject;
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
        replyAction.title = objcL10n.reply;
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

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FASTLANE_SNAPSHOT"]) {
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:types
                                          categories:[NSSet setWithObjects:completeCategory, questInviteCategory, privateMessageCategory, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self.swiftAppDelegate saveDeviceToken:deviceToken];
}

- (void)completeTaskWithId:(NSString *)taskID completionHandler:(void (^)(void))completionHandler {
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
