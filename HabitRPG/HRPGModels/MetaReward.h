//
//  MetaReward.h
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface MetaReward : NSManagedObject

@property(nonatomic, retain) NSNumber *buyable;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSNumber *value;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSString *rewardType;

@end
