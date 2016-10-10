//
//  Buff+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "Buff+CoreDataProperties.h"

@implementation Buff (CoreDataProperties)

+ (NSFetchRequest<Buff *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Buff"];
}

@dynamic constitution;
@dynamic intelligence;
@dynamic perception;
@dynamic seafoam;
@dynamic shinySeed;
@dynamic snowball;
@dynamic spookySparkles;
@dynamic strength;
@dynamic streak;
@dynamic userID;
@dynamic user;

@end
