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
    [self.buttons configureForTask:task];
    self.rightBorderView.backgroundColor = [task lightTaskColor];

    // Until we save the TaskHistory just set the last action to be hidden
    self.notesLastActionConstraint.constant = 0;
}

@end
