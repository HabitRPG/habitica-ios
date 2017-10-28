//
//  ChallengeTask+CoreDataClass.m
//  Habitica
//
//  Created by Phillip Thelen on 13/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "ChallengeTask+CoreDataClass.h"
#import "Challenge+CoreDataClass.h"
#import "UIColor+Habitica.h"

@implementation ChallengeTask

- (UIColor *)taskColor {
    NSInteger intValue = [self.value integerValue];
    if (intValue < -20) {
        return [UIColor darkRed50];
    } else if (intValue < -10) {
        return [UIColor red50];
    } else if (intValue < -1) {
        return [UIColor orange50];
    } else if (intValue < 1) {
        return [UIColor yellow50];
    } else if (intValue < 5) {
        return [UIColor green50];
    } else if (intValue < 10) {
        return [UIColor teal50];
    } else {
        return [UIColor blue50];
    }
}

- (UIColor *)lightTaskColor {
    NSInteger intValue = [self.value integerValue];
    if (intValue < -20) {
        return [UIColor darkRed100];
    } else if (intValue < -10) {
        return [UIColor red100];
    } else if (intValue < -1) {
        return [UIColor orange100];
    } else if (intValue < 1) {
        return [UIColor yellow100];
    } else if (intValue < 5) {
        return [UIColor green100];
    } else if (intValue < 10) {
        return [UIColor teal100];
    } else {
        return [UIColor blue100];
    }
}

@end
