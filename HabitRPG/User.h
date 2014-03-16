//
//  User.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Reward, Task;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * experience;
@property (nonatomic, retain) NSNumber * gold;
@property (nonatomic, retain) NSString * hclass;
@property (nonatomic, retain) NSNumber * health;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * magic;
@property (nonatomic, retain) NSNumber * maxHealth;
@property (nonatomic, retain) NSNumber * maxMagic;
@property (nonatomic, retain) NSNumber * nextLevel;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSManagedObject *party;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *tasks;
@property (nonatomic, retain) Reward *rewards;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(NSManagedObject *)value;
- (void)removeGroupsObject:(NSManagedObject *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
