//
//  User.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Reward, Tag, Task;

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
@property (nonatomic) BOOL sleep;
@property (nonatomic, retain) NSNumber * dayStart;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) Group *party;
@property (nonatomic, retain) Reward *rewards;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
