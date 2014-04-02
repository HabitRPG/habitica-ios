//
//  QuestCollect.h
//  HabitRPG
//
//  Created by Phillip Thelen on 02/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Quest;

@interface QuestCollect : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Quest *quest;

@end
