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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    isEditing = editing;
    
    if ([self.taskType isEqualToString:@"h"]) {
        if (isEditing) {
            [self viewWithTag:3].alpha = 0;
            [self viewWithTag:2].alpha = 0;
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self viewWithTag:3].alpha = 1;
                [self viewWithTag:2].alpha = 1;
            });
        }
    }
}


@end
