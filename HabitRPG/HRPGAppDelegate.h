//
//  HRPGAppDelegate.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OIDExternalUserAgentSession;
@class HabiticaAppDelegate;

@interface HRPGAppDelegate : UIResponder<UIApplicationDelegate, UIAlertViewDelegate>

@property(strong, nonatomic, nullable) UIWindow *window;
@property(strong, nonatomic, nonnull) HabiticaAppDelegate *swiftAppDelegate;

@property(nonatomic, strong, nullable)id<OIDExternalUserAgentSession> currentAuthorizationFlow;
@end
