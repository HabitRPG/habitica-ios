//
//  Reward.h
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Reward : NSManagedObject

@property(nonatomic, retain) NSDate *dateCreated;
@property(nonatomic, retain) User *user;

@end
