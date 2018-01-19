//
//  Quest+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip on 28.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Quest+CoreDataProperties.h"

@implementation Quest (CoreDataProperties)

+ (NSFetchRequest<Quest *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Quest"];
}

@dynamic bossDef;
@dynamic bossHp;
@dynamic bossName;
@dynamic bossRage;
@dynamic bossStr;
@dynamic completition;
@dynamic dropExp;
@dynamic dropGp;
@dynamic previous;
@dynamic rageDescription;
@dynamic rageTitle;
@dynamic collect;
@dynamic user;
@dynamic itemDrops;
@dynamic colorDark;
@dynamic colorMedium;
@dynamic colorLight;
@dynamic colorExtraLight;

@end
