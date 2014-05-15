//
//  HRPGAppDelegate.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGAppDelegate.h"
#import "Task.h"
#import "CRToast.h"
#import <Crashlytics/Crashlytics.h>
#if !defined (CONFIGURATION_AppStore_Distribution)
#import "BWHockeyManager.h"
#endif

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"2eb3b3edb3b0f4722d37d649a5af366656e46ddd"];
    
    
#if !defined (CONFIGURATION_AppStore_Distribution)
    [BWHockeyManager sharedHockeyManager].updateURL = @"https://viirus.sirius.uberspace.de/hockeykit/";
#endif
    
    CRToastInteractionResponder *blankResponder = [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeAll automaticallyDismiss:YES block:^(CRToastInteractionType interactionType){
    }];
    [CRToastManager setDefaultOptions:@{kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                        kCRToastAnimationInTimeIntervalKey : @(0.5),
                                        kCRToastAnimationOutTimeIntervalKey: @(0.5),
                                        kCRToastFontKey: [UIFont systemFontOfSize:17],
                                        kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                                        kCRToastInteractionRespondersKey:@[blankResponder]
                                        }];
    
    _sharedManager = [[HRPGManager alloc] init];
    [_sharedManager loadObjectManager];
    //Update Content if it wasn't updated in the last week.
    NSDate *lastContentFetch = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastContentFetch"];
    if (lastContentFetch == nil || [lastContentFetch timeIntervalSinceNow] < -604800) {
        [_sharedManager fetchContent:^() {
        } onError:^() {
        }];
    }
    NSArray* scheduledNotifications = [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;
    return YES;
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    NSArray* scheduledNotifications = [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;
}

@end
