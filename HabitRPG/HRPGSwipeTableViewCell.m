//
//  HRPGSwipeTableViewCell.m
//  HabitRPG
//
//  Created by Phillip Thelen on 20/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSwipeTableViewCell.h"

@implementation HRPGSwipeTableViewCell

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    isEditing = editing;
}


@end
