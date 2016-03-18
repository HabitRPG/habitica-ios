//
//  HatchingPotion.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class User;

@interface HatchingPotion : Item

@property(nonatomic, retain) User *user;

@end
