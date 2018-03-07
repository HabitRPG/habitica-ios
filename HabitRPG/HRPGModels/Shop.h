//
//  Shop.h
//  Habitica
//
//  Created by Phillip Thelen on 12/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Shop : NSManagedObject

extern NSString *const MarketKey;
extern NSString *const GearMarketKey;
extern NSString *const QuestsShopKey;
extern NSString *const TimeTravelersShopKey;
extern NSString *const SeasonalShopKey;

@end

NS_ASSUME_NONNULL_END

#import "Shop+CoreDataProperties.h"
