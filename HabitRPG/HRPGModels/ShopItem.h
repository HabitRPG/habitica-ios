//
//  ShopItem.h
//  Habitica
//
//  Created by Phillip Thelen on 12/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ShopCategory;

NS_ASSUME_NONNULL_BEGIN

@interface ShopItem : NSManagedObject

- (NSString *)readableUnlockCondition;

@end

NS_ASSUME_NONNULL_END

#import "ShopItem+CoreDataProperties.h"
