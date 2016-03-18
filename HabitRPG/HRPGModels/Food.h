//
//  Food.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BuyableItem.h"

@class User;

@interface Food : BuyableItem

@property(nonatomic, retain) NSString *article;
@property(nonatomic, retain) NSString *target;
@property(nonatomic, retain) User *user;

@end
