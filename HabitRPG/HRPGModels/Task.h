//
//  Task.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class ChecklistItem, Tag, User, Reminder;

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

@interface Task : NSManagedObject

@property(nonatomic, retain) NSString *attribute;
@property(nonatomic, retain) NSNumber *completed;
@property(nonatomic, retain) NSString *challengeID;
@property(nonatomic, retain) NSDate *dateCreated;
@property(nonatomic, retain) NSDate *duedate;
@property(nonatomic, retain) NSNumber *down;
@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSNumber *order;
@property(nonatomic, retain) NSNumber *priority;
@property(nonatomic, retain) NSNumber *streak;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSNumber *up;
@property(nonatomic, retain) NSNumber *value;
@property(nonatomic, retain) NSNumber *monday;
@property(nonatomic, retain) NSNumber *tuesday;
@property(nonatomic, retain) NSNumber *wednesday;
@property(nonatomic, retain) NSNumber *thursday;
@property(nonatomic, retain) NSNumber *friday;
@property(nonatomic, retain) NSNumber *saturday;
@property(nonatomic, retain) NSNumber *sunday;
@property(nonatomic, retain) NSNumber *everyX;
@property(nonatomic, retain) NSString *frequency;
@property(nonatomic, retain) NSDate *startDate;
@property(nonatomic, retain) NSOrderedSet *checklist;
@property(nonatomic, retain) NSSet *tags;
@property(nonatomic, retain) NSOrderedSet *reminders;
@property(nonatomic) NSArray *tagArray;
@property(nonatomic, retain) User *user;

// Temporary variable to store whether or not the task is currently being checked or not. Used to
// preved doubletapping on a daily and receiving twice the bonus
@property(nonatomic, retain) NSNumber *currentlyChecking;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)insertObject:(ChecklistItem *)value inChecklistAtIndex:(NSUInteger)idx;

- (void)removeObjectFromChecklistAtIndex:(NSUInteger)idx;

- (void)insertChecklist:(NSArray *)value atIndexes:(NSIndexSet *)indexes;

- (void)removeChecklistAtIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectInChecklistAtIndex:(NSUInteger)idx withObject:(ChecklistItem *)value;

- (void)replaceChecklistAtIndexes:(NSIndexSet *)indexes withChecklist:(NSArray *)values;

- (void)addChecklistObject:(ChecklistItem *)value;

- (void)removeChecklistObject:(ChecklistItem *)value;

- (void)addChecklist:(NSOrderedSet *)values;

- (void)removeChecklist:(NSOrderedSet *)values;

- (void)addTagsObject:(Tag *)value;

- (void)removeTagsObject:(Tag *)value;

- (void)addTags:(NSSet *)values;

- (void)removeTags:(NSSet *)values;

- (void)addRemindersObject:(Reminder *)value;

- (void)removeRemindersObject:(Reminder *)value;

- (void)addReminders:(NSSet *)values;

- (void)removeReminders:(NSSet *)values;

- (BOOL)dueToday;
- (BOOL)dueTodayWithOffset:(NSInteger)offset;
- (BOOL)dueOnDate:(NSDate *)date;
- (BOOL)dueOnDate:(NSDate *)date withOffset:(NSInteger)offset;

- (UIColor *)taskColor;
- (UIColor *)lightTaskColor;

+ (NSArray *)predicatesForTaskType:(NSString *)taskType withFilterType:(NSInteger)filterType;

@end
