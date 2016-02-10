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
@dynamic likes;

-(UIColor *)contributorColor {
    if ([self.contributorLevel integerValue] == 1) {
        return [UIColor colorWithRed:0.941 green:0.380 blue:0.549 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 2) {
        return [UIColor colorWithRed:0.659 green:0.118 blue:0.141 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 3) {
        return [UIColor colorWithRed:0.984 green:0.098 blue:0.031 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 4) {
        return [UIColor colorWithRed:0.992 green:0.506 blue:0.031 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 5) {
        return [UIColor colorWithRed:0.806 green:0.779 blue:0.284 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 6) {
        return [UIColor colorWithRed:0.333 green:1.000 blue:0.035 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 7) {
        return [UIColor colorWithRed:0.071 green:0.592 blue:1.000 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 8) {
        return [UIColor colorWithRed:0.055 green:0.000 blue:0.876 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 9) {
        return [UIColor colorWithRed:0.455 green:0.000 blue:0.486 alpha:1.000];
    }
    return [UIColor grayColor];
}

@end
