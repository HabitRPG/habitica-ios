//
//  Task.h
//  HabitRPG
//
//  Created by Phillip Thelen on 09/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * attribute;
@property (nonatomic) bool completed;
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
@property (nonatomic, retain) NSOrderedSet *checklist;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSManagedObject *user;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)addChecklistObject:(NSManagedObject *)value;
- (void)removeChecklistObject:(NSManagedObject *)value;
- (void)addChecklist:(NSSet *)values;
- (void)removeChecklist:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
