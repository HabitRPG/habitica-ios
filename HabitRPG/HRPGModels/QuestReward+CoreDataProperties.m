//
//  QuestReward+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip on 28.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "QuestReward+CoreDataProperties.h"

@implementation QuestReward (CoreDataProperties)

+ (NSFetchRequest<QuestReward *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"QuestReward"];
}

@dynamic text;
@dynamic key;
@dynamic type;
@dynamic onlyOwner;
@dynamic quest;

@end
