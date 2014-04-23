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

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"2eb3b3edb3b0f4722d37d649a5af366656e46ddd"];
    [CRToastManager setDefaultOptions:@{kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                        kCRToastAnimationInTimeIntervalKey : @(0.5),
                                        kCRToastAnimationOutTimeIntervalKey: @(0.5),
                                        kCRToastFontKey: [UIFont systemFontOfSize:17],
                                        kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover)}];
    
    _sharedManager = [[HRPGManager alloc] init];
    [_sharedManager loadObjectManager];
    //Update Content if it wasn't updated in the last week.
    NSDate *lastContentFetch = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastContentFetch"];
    NSLog(@"%@ - %f", lastContentFetch, [lastContentFetch timeIntervalSinceNow]);
    if (lastContentFetch == nil || [lastContentFetch timeIntervalSinceNow] < -604800) {
        [_sharedManager fetchContent:^() {
        } onError:^() {
        }];
    }
    return YES;
}

@end
