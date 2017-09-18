//
//  InAppReward+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip on 18.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//

#import "InAppReward+CoreDataProperties.h"

@implementation InAppReward (CoreDataProperties)

+ (NSFetchRequest<InAppReward *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"InAppReward"];
}

@dynamic currency;
@dynamic imageName;
@dynamic isSuggested;
@dynamic locked;
@dynamic path;
@dynamic pinType;
@dynamic purchaseType;
@dynamic lastPurchased;

@end
