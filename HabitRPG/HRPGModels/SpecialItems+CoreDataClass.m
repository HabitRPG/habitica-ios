//
//  SpecialItems+CoreDataClass.m
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "SpecialItems+CoreDataClass.h"
#import "User.h"
@implementation SpecialItems

- (NSArray *)ownedTransformationItemIDs {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    if ([self.seafoam integerValue]) {
        [items addObject:@"seafoam"];
    }
    if ([self.shinySeed integerValue]) {
        [items addObject:@"shinySeed"];
    }
    if ([self.spookySparkles integerValue]) {
        [items addObject:@"spookySparkles"];
    }
    if ([self.snowball integerValue]) {
        [items addObject:@"snowball"];
    }
    return items;
}


@end
