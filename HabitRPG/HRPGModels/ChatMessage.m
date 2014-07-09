//
//  ChatMessage.m
//  HabitRPG
//
//  Created by Phillip Thelen on 02/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "ChatMessage.h"


@implementation ChatMessage

@dynamic id;
@dynamic text;
@dynamic timestamp;
@dynamic user;
@dynamic uuid;
@dynamic group;
@dynamic userObject;
@dynamic contributorLevel;
@dynamic backerNpc;

-(UIColor *)contributorColor {
    if (self.backerNpc) {
        return [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
    }
    
    if ([self.contributorLevel integerValue] == 0) {
        
    } else if ([self.contributorLevel integerValue] <= 2) {
        return [UIColor colorWithWhite:0.200 alpha:1.000];
    } else if ([self.contributorLevel integerValue] <= 4) {
        return [UIColor colorWithRed:0.027 green:0.455 blue:0.035 alpha:1.000];
    } else if ([self.contributorLevel integerValue] <= 6) {
        return [UIColor colorWithRed:0.067 green:0.357 blue:0.635 alpha:1.000];
    } else if ([self.contributorLevel integerValue] <= 7) {
        return [UIColor colorWithRed:0.451 green:0.071 blue:0.706 alpha:1.000];
    } else if ([self.contributorLevel integerValue] <= 8) {
        return [UIColor colorWithRed:1.000 green:0.506 blue:0.000 alpha:1.000];
    }
    return [UIColor grayColor];
}
@end
