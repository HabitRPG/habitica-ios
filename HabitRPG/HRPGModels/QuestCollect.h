//
//  QuestCollect.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class Group, Quest;

@interface QuestCollect : NSManagedObject

@property(nonatomic, retain) NSNumber *count;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSNumber *collectCount;
@property(nonatomic, retain) Quest *quest;
@property(nonatomic, retain) Group *group;

@end
