//
//  Potion.m
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Potion.h"


@implementation Potion

- (void)willSave {
    if (![self.rewardType isEqualToString:@"potion"]) {
        self.rewardType = @"potion";
    }}

@end
