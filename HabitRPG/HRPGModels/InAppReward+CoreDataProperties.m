//
//  InAppReward+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "InAppReward+CoreDataProperties.h"

@implementation InAppReward (CoreDataProperties)

+ (NSFetchRequest<InAppReward *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"InAppReward"];
}

@dynamic text;
@dynamic key;
@dynamic notes;
@dynamic purchaseType;
@dynamic pinType;
@dynamic path;
@dynamic isSuggested;
@dynamic locked;
@dynamic value;
@dynamic currency;
@dynamic imageName;

@end
