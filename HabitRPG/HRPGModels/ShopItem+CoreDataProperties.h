//
//  ShopItem+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip on 18.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//

#import "ShopItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ShopItem (CoreDataProperties)

+ (NSFetchRequest<ShopItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *availableUntil;
@property (nullable, nonatomic, copy) NSString *currency;
@property (nullable, nonatomic, copy) NSString *imageName;
@property (nullable, nonatomic, copy) NSNumber *index;
@property (nullable, nonatomic, copy) NSNumber *isSubscriberItem;
@property (nullable, nonatomic, copy) NSNumber *itemsLeft;
@property (nullable, nonatomic, copy) NSString *key;
@property (nullable, nonatomic, copy) NSNumber *locked;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *path;
@property (nullable, nonatomic, copy) NSString *pinType;
@property (nullable, nonatomic, copy) NSString *purchaseType;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *unlockCondition;
@property (nullable, nonatomic, copy) NSNumber *value;
@property (nullable, nonatomic, copy) NSNumber *owned;
@property (nullable, nonatomic, copy) NSNumber *pinned;
@property (nullable, nonatomic, copy) NSDate *lastPurchased;
@property (nullable, nonatomic, retain) ShopCategory *category;

@end

NS_ASSUME_NONNULL_END
