//
//  HRPGLoginIncentiveNotification.h
//  Habitica
//
//  Created by Phillip Thelen on 20/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRPGBaseNotificationView.h"
#import "User.h"

@interface HRPGLoginIncentiveNotification : HRPGBaseNotificationView

@property User *user;

@end
