//
//  HRPGSwipeTableViewCell.m
//  HabitRPG
//
//  Created by Phillip Thelen on 20/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSwipeTableViewCell.h"

@implementation HRPGSwipeTableViewCell
BOOL isEditing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    isEditing = editing;
}



@end
