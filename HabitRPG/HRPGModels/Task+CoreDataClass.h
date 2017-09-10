//
//  Task+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChecklistItem, Reminder, Tag, User;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskHabitFilterType) {
    TaskHabitFilterTypeAll,
    TaskHabitFilterTypeWeak,
    TaskHabitFilterTypeStrong
};

typedef NS_ENUM(NSInteger, TaskDailyFilterType) {
    TaskDailyFilterTypeAll,
    TaskDailyFilterTypeDue,
    TaskDailyFilterTypeGrey
};

typedef NS_ENUM(NSInteger, TaskToDoFilterType) {
    TaskToDoFilterTypeActive,
    TaskToDoFilterTypeDated,
    TaskToDoFilterTypeDone
};

@interface OldTask : NSManagedObject

@property(nonatomic) NSArray *tagArray;
// Temporary variable to store whether or not the task is currently being checked or not. Used to
// preved doubletapping on a daily and receiving twice the bonus
@property(nonatomic, retain) NSNumber *currentlyChecking;

- (BOOL)dueToday;
- (BOOL)dueTodayWithOffset:(NSInteger)offset;
- (BOOL)dueOnDate:(NSDate *)date;
- (BOOL)dueOnDate:(NSDate *)date withOffset:(NSInteger)offset;

- (UIColor *)taskColor;
- (UIColor *)lightTaskColor;

- (BOOL)allWeekdaysInactive;

+ (NSArray *)predicatesForTaskType:(NSString *)taskType withFilterType:(NSInteger)filterType withOffset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END

#import "Task+CoreDataProperties.h"
