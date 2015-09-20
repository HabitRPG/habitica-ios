//
//  HRPGAppDelegate.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGAppDelegate.h"
#import "HRPGTableViewController.h"
#import "CRToast.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <CargoBay.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/Analytics.h>

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
        /*UINavigationController *navigationController = (UINavigationController *) ((UITabBarController *) self.window.rootViewController).selectedViewController;
        UIViewController *visibleView = navigationController.visibleViewController;
        HRPGTableViewController *viewController;
        if ([visibleView isKindOfClass:[HRPGTableViewController class]]) {
            viewController = (HRPGTableViewController *) visibleView;
            [viewController.refreshControl beginRefreshing];
        }
        [self.sharedManager fetchUser:^() {
            if (viewController) {
                [viewController.refreshControl endRefreshing];
            }
        }                 onError:^() {
            if (viewController) {
                [viewController.refreshControl endRefreshing];
            }
        }];*/
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

@end
