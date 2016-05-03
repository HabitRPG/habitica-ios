//
//  ChecklistItem.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class Task;

@interface ChecklistItem : NSManagedObject

@property(nonatomic, retain) NSNumber *completed;
@property(nonatomic, retain) NSNumber *currentlyChecking;
@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) Task *task;

@end
