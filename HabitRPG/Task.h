//
//  Task.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChecklistItem, Tag, User;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * attribute;
@property (nonatomic) BOOL completed;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic) BOOL down;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * streak;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;
@property (nonatomic) BOOL up;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic) BOOL monday;
@property (nonatomic) BOOL tuesday;
@property (nonatomic) BOOL wednesday;
@property (nonatomic) BOOL thursday;
@property (nonatomic) BOOL friday;
@property (nonatomic) BOOL saturday;
@property (nonatomic) BOOL sunday;
@property (nonatomic, retain) NSOrderedSet *checklist;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) User *user;
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
- (BOOL)dueToday;

@end
