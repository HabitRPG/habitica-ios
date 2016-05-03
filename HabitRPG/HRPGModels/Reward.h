//
//  Reward.h
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "MetaReward.h"
#import "Tag.h"

@class User;

@interface Reward : MetaReward

@property(nonatomic, retain) NSDate *dateCreated;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) NSSet *tags;
@property(nonatomic) NSArray *tagArray;

- (void)addTagsObject:(Tag *)value;

- (void)removeTagsObject:(Tag *)value;

- (void)addTags:(NSSet *)values;

- (void)removeTags:(NSSet *)values;

@end
