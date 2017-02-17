//
//  HRPGHabitTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitTableViewCell.h"

@implementation HRPGHabitTableViewCell

- (void)configureForTask:(Task *)task {
    [super configureForTask:task];
    [self.plusButton configureForTask:task isNegative:NO];
    [self.minusButton configureForTask:task isNegative:YES];
}

@end
