//
//  HRPGHabitTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitButtons.h"
#import "HRPGTaskTableViewCell.h"

@interface HRPGHabitTableViewCell : HRPGTaskTableViewCell

@property(weak, nonatomic) IBOutlet HRPGHabitButtons *buttons;
@property(weak, nonatomic) IBOutlet UIView *rightBorderView;
@property(weak, nonatomic) IBOutlet UILabel *lastactionLabel;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *notesLastActionConstraint;
@end
