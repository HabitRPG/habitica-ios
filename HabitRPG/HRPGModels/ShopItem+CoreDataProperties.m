//
//  ShopItem+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 14/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "ShopItem+CoreDataProperties.h"

@implementation ShopItem (CoreDataProperties)

+ (NSFetchRequest<ShopItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ShopItem"];
}

@dynamic currency;
@dynamic imageName;
@dynamic index;
@dynamic key;
@dynamic locked;
@dynamic notes;
@dynamic purchaseType;
@dynamic text;
@dynamic type;
@dynamic unlockCondition;
@dynamic value;
@dynamic isSubscriberItem;
@dynamic itemsLeft;
@dynamic category;
@dynamic path;
@dynamic pinType;

@end
