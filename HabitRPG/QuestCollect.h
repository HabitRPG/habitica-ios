//
//  QuestCollect.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Quest;

@interface QuestCollect : NSManagedObject

@property(nonatomic, retain) NSNumber *count;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSNumber *collectCount;
@property(nonatomic, retain) Quest *quest;
@property(nonatomic, retain) Group *group;

@end
