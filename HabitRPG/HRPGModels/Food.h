//
//  Food.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "BuyableItem.h"

@class User;

@interface Food : BuyableItem

@property(nonatomic, retain) NSString *article;
@property(nonatomic, retain) NSString *target;
@property(nonatomic, retain) User *user;

@end
