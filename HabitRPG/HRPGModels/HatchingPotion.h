//
//  HatchingPotion.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "Item.h"

@class User;

@interface HatchingPotion : Item

@property(nonatomic, retain) User *user;

@end
