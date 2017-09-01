//
//  HRPGBaseNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 03/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGBaseNotificationView.h"

@implementation HRPGBaseNotificationView

- (void)displayNotification:(void (^)())completionBlock {
    [self doesNotRecognizeSelector:_cmd];
}

@end
