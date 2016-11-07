//
//  HRPGBaseNotification.h
//  Habitica
//
//  Created by Phillip Thelen on 03/11/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRPGNotification.h"
#import "UIWindow+VisibleController.h"

@interface HRPGBaseNotificationView : NSObject

@property HRPGNotification *notification;

- (void)displayNotification:(void (^)())completionBlock;

@end
