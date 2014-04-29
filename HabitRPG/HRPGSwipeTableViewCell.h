//
//  HRPGSwipeTableViewCell.h
//  HabitRPG
//
//  Created by Phillip Thelen on 20/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

@interface HRPGSwipeTableViewCell : MCSwipeTableViewCell

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection) {
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};

- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction;
- (void)animateWithOffset:(CGFloat)offset;

@end
