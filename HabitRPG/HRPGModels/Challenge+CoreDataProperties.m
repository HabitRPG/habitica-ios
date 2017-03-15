//
//  Challenge+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 14/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "Challenge+CoreDataProperties.h"

@implementation Challenge (CoreDataProperties)

+ (NSFetchRequest<Challenge *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Challenge"];
}

@dynamic createdAt;
@dynamic id;
@dynamic leaderId;
@dynamic leaderName;
@dynamic memberCount;
@dynamic name;
@dynamic notes;
@dynamic official;
@dynamic prize;
@dynamic shortName;
@dynamic updatedAt;
@dynamic group;
@dynamic habits;
@dynamic user;
@dynamic dailies;
@dynamic todos;
@dynamic rewards;

@end
