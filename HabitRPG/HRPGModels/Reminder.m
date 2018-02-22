//
//  Reminder.m
//  Habitica
//
//  Created by Phillip Thelen on 23/12/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Reminder.h"
#import "Task+CoreDataClass.h"

@implementation Reminder

- (void)willSave {
    if (self.hasChanges) {
            if (self.inserted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scheduleReminders];
                });
            } else {
                if (self.updated) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self removeAllNotifications];
                        [self scheduleReminders];
                    });
                }
                if (self.deleted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self removeAllNotifications];
                    });
                }
            }
    }
    [super didSave];
}

- (void)removeAllNotifications {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    for (UILocalNotification *reminder in [sharedApplication scheduledLocalNotifications]) {
        if ([reminder.userInfo[@"ID"] isEqualToString:self.id]) {
            [sharedApplication cancelLocalNotification:reminder];
        }
    }
}

- (void)removeTodaysNotifications {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    for (UILocalNotification *reminder in [sharedApplication scheduledLocalNotifications]) {
        if ([reminder.userInfo[@"ID"] isEqualToString:self.id] &&
            [self isSameDayWithDate1:[NSDate date] date2:reminder.fireDate]) {
            [sharedApplication cancelLocalNotification:reminder];
        }
    }
}

- (void)scheduleReminders {
    if (self.task) {
        if ([self.task.completed boolValue]) {
            return;
        }
    } else {
        return;
    }
    if ([self.task.type isEqualToString:@"daily"]) {
        for (int day = 0; day < 6; day++) {
            NSDate *checkedDate = [NSDate dateWithTimeIntervalSinceNow:(day * 86400)];
            if ([self.task dueOnDate:checkedDate]) {
                [self scheduleForDay:checkedDate];
            }
        }
    } else {
        if ([self.time compare:[NSDate date]] == NSOrderedDescending) {
            [self scheduleForDay:self.time];
        }
    }
}

- (void)scheduleForDay:(NSDate *)day {
    NSDate *fireDate;
    if (day) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents =
            [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                        fromDate:day];
        NSDateComponents *timeComponents =
            [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute
                                            fromDate:self.time];
        [dateComponents setHour:timeComponents.hour];
        [dateComponents setMinute:timeComponents.minute];
        fireDate = [calendar dateFromComponents:dateComponents];
    } else {
        fireDate = self.time;
    }

    if ([fireDate compare:[NSDate date]] != NSOrderedDescending) {
        return;
    }

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = self.task.text;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    if (self.task.type && self.task.id) {
        localNotification.userInfo =
            @{ @"ID" : self.id,
               @"taskID" : self.task.id,
               @"taskType" : self.task.type };
    } else {
        localNotification.userInfo = @{ @"ID" : self.id };
    }
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    if ([localNotification respondsToSelector:@selector(setCategory:)]) {
        localNotification.category = @"completeCategory";
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (BOOL)isSameDayWithDate1:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date2];

    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] &&
           [comp1 year] == [comp2 year];
}

@end
