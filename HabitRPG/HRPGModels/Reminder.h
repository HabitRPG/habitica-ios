//
//  Reminder.h
//  Habitica
//
//  Created by Phillip Thelen on 23/12/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task;

NS_ASSUME_NONNULL_BEGIN

@interface Reminder : NSManagedObject

- (void) scheduleReminders;
- (void) scheduleForDay:(NSDate *) day;
- (void) removeTodaysNotifications;
- (void) removeAllNotifications;

@end

NS_ASSUME_NONNULL_END

#import "Reminder+CoreDataProperties.h"
