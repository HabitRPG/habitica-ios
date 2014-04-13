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
#import "BWQuincyManager.h"

@implementation HRPGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    //[_sharedManager fetchTasks:^() {
    //} onError:^() {
    //}];
    //[_sharedManager fetchContent:^() {
    //} onError:^() {
    //}];
    [[BWQuincyManager sharedQuincyManager] setSubmissionURL:@"http://viirus.sirius.uberspace.de/quincy/crash_v300.php"]; [[BWQuincyManager sharedQuincyManager] startManager];
    return YES;
}

@end
