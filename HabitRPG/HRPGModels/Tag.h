//
//  Tag.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class Task, User;

@interface Tag : NSManagedObject

@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSSet *tasks;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) NSNumber *hasTasks;
@property(nonatomic, retain) NSNumber *challenge;
@property(nonatomic, retain) NSNumber *order;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Task *)value;

- (void)removeTasksObject:(Task *)value;

- (void)addTasks:(NSSet *)values;

- (void)removeTasks:(NSSet *)values;

@end
