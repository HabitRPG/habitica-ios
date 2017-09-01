//
//  HRPGNotification.h
//  Habitica
//
//  Created by Phillip Thelen on 02/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGNotification : NSObject

@property NSString *type;
@property NSDate *createdAt;
@property NSDictionary *data;
@property NSString *id;

@end
