//
//  ShopItem+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip on 18.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//

#import "ShopItem+CoreDataProperties.h"

@implementation ShopItem (CoreDataProperties)

+ (NSFetchRequest<ShopItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ShopItem"];
}

@dynamic availableUntil;
@dynamic currency;
@dynamic imageName;
@dynamic index;
@dynamic isSubscriberItem;
@dynamic itemsLeft;
@dynamic key;
@dynamic locked;
@dynamic notes;
@dynamic path;
@dynamic pinType;
@dynamic purchaseType;
@dynamic text;
@dynamic type;
@dynamic unlockCondition;
@dynamic value;
@dynamic lastPurchased;
@dynamic category;

@end
