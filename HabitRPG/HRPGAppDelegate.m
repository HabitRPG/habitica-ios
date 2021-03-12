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
#if DEBUG
    [[SDStatusBarManager sharedInstance] enableOverrides];
#endif
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        
    return YES;
}


- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
    [self.swiftAppDelegate displayInAppNotificationWithTaskID:[notification.userInfo valueForKey:@"taskID"] text:notification.alertBody];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if ([userInfo[@"aps"][@"alert"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = userInfo[@"aps"][@"alert"];
            [self.swiftAppDelegate displayNotificationInAppWithTitle:dict[@"title"] text:dict[@"body"]];
        } else {
            [self.swiftAppDelegate displayNotificationInAppWithText:userInfo[@"aps"][@"alert"]];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)completeTaskWithId:(NSString *)taskID completionHandler:(void (^)(void))completionHandler {
    [self.swiftAppDelegate scoreTask:taskID direction:@"up" completed: ^() {
        if (completionHandler) {
            completionHandler();
        };
    }];
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
