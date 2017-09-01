//
//  ShopItem+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 14/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ShopCategory.h"
#import "MetaReward.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShopItem : MetaReward

- (NSString *)readableUnlockCondition;
- (BOOL)canBuy:(NSNumber *)currencyAmount;

@end

NS_ASSUME_NONNULL_END

#import "ShopItem+CoreDataProperties.h"
