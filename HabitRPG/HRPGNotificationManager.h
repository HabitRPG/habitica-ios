//
//  HRPGNotificationManager.h
//  Habitica
//
//  Created by Phillip Thelen on 02/11/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRPGNotification.h"
#import "HRPGManager.h"

@interface HRPGNotificationManager : NSObject

- (instancetype)initWithSharedManager:(HRPGManager *)sharedManager;

- (void)enqueueNotification:(HRPGNotification *) notification;

- (void)enqueueNotifications:(NSArray *)notifications;

@end
