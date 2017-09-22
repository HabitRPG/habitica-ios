//
//  ShopCategory+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip on 22.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//

#import "ShopCategory+CoreDataProperties.h"

@implementation ShopCategory (CoreDataProperties)

+ (NSFetchRequest<ShopCategory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ShopCategory"];
}

@dynamic identifier;
@dynamic index;
@dynamic notes;
@dynamic purchaseAll;
@dynamic text;
@dynamic pinType;
@dynamic path;
@dynamic items;
@dynamic shop;

@end
