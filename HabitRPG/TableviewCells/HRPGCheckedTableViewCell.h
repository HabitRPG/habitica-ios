//
//  HRPGCheckedTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "ChecklistItem.h"
#import "HRPGCheckBoxView.h"
#import "HRPGTaskTableViewCell.h"
#import "Task.h"

@interface HRPGCheckedTableViewCell : HRPGTaskTableViewCell
@property(weak, nonatomic) IBOutlet HRPGCheckBoxView *checkBox;
@property(weak, nonatomic) IBOutlet UIView *checklistIndicator;
@property(weak, nonatomic) IBOutlet UILabel *checklistDoneLabel;
@property(weak, nonatomic) IBOutlet UILabel *checklistAllLabel;
@property(weak, nonatomic) IBOutlet UIView *checklistSeparator;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *checklistIndicatorWidth;

- (void)configureForItem:(ChecklistItem *)item forTask:(Task *)task;

@end
