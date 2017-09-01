//
//  SpecialItems+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "SpecialItems+CoreDataProperties.h"

@implementation SpecialItems (CoreDataProperties)

+ (NSFetchRequest<SpecialItems *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SpecialItems"];
}

@dynamic spookySparkles;
@dynamic seafoam;
@dynamic shinySeed;
@dynamic snowball;
@dynamic valentine;
@dynamic nye;
@dynamic greeting;
@dynamic thankyou;
@dynamic birthday;
@dynamic user;

@end
