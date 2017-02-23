//
//  Task+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "Task+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *attribute;
@property (nullable, nonatomic, copy) NSString *challengeID;
@property (nullable, nonatomic, copy) NSNumber *completed;
@property (nullable, nonatomic, copy) NSDate *dateCreated;
@property (nullable, nonatomic, copy) NSNumber *down;
@property (nullable, nonatomic, copy) NSDate *duedate;
@property (nullable, nonatomic, copy) NSNumber *everyX;
@property (nullable, nonatomic, copy) NSString *frequency;
@property (nullable, nonatomic, copy) NSNumber *friday;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSNumber *monday;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSNumber *priority;
@property (nullable, nonatomic, copy) NSNumber *saturday;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSNumber *streak;
@property (nullable, nonatomic, copy) NSNumber *sunday;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSNumber *thursday;
@property (nullable, nonatomic, copy) NSNumber *tuesday;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSNumber *up;
@property (nullable, nonatomic, copy) NSNumber *value;
@property (nullable, nonatomic, copy) NSNumber *wednesday;
@property (nullable, nonatomic, retain) NSOrderedSet<ChecklistItem *> *checklist;
@property (nullable, nonatomic, retain) NSOrderedSet<TaskHistory *> *history;
@property (nullable, nonatomic, retain) NSOrderedSet<Reminder *> *reminders;
@property (nullable, nonatomic, retain) NSSet<Tag *> *tags;
@property (nullable, nonatomic, retain) User *user;

@end

@interface Task (CoreDataGeneratedAccessors)

- (void)insertObject:(ChecklistItem *)value inChecklistAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChecklistAtIndex:(NSUInteger)idx;
- (void)insertChecklist:(NSArray<ChecklistItem *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChecklistAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChecklistAtIndex:(NSUInteger)idx withObject:(ChecklistItem *)value;
- (void)replaceChecklistAtIndexes:(NSIndexSet *)indexes withChecklist:(NSArray<ChecklistItem *> *)values;
- (void)addChecklistObject:(ChecklistItem *)value;
- (void)removeChecklistObject:(ChecklistItem *)value;
- (void)addChecklist:(NSOrderedSet<ChecklistItem *> *)values;
- (void)removeChecklist:(NSOrderedSet<ChecklistItem *> *)values;

- (void)insertObject:(TaskHistory *)value inHistoryAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHistoryAtIndex:(NSUInteger)idx;
- (void)insertHistory:(NSArray<TaskHistory *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHistoryAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHistoryAtIndex:(NSUInteger)idx withObject:(TaskHistory *)value;
- (void)replaceHistoryAtIndexes:(NSIndexSet *)indexes withHistory:(NSArray<TaskHistory *> *)values;
- (void)addHistoryObject:(TaskHistory *)value;
- (void)removeHistoryObject:(TaskHistory *)value;
- (void)addHistory:(NSOrderedSet<TaskHistory *> *)values;
- (void)removeHistory:(NSOrderedSet<TaskHistory *> *)values;

- (void)insertObject:(Reminder *)value inRemindersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRemindersAtIndex:(NSUInteger)idx;
- (void)insertReminders:(NSArray<Reminder *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRemindersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRemindersAtIndex:(NSUInteger)idx withObject:(Reminder *)value;
- (void)replaceRemindersAtIndexes:(NSIndexSet *)indexes withReminders:(NSArray<Reminder *> *)values;
- (void)addRemindersObject:(Reminder *)value;
- (void)removeRemindersObject:(Reminder *)value;
- (void)addReminders:(NSOrderedSet<Reminder *> *)values;
- (void)removeReminders:(NSOrderedSet<Reminder *> *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet<Tag *> *)values;
- (void)removeTags:(NSSet<Tag *> *)values;

@end

NS_ASSUME_NONNULL_END
