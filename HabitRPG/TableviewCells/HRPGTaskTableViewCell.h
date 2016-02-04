//
//  HRPGTaskTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface HRPGTaskTableViewCell : UITableViewCell

- (void)configureForTask:(Task *) task;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleNoteConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView;
@property (weak, nonatomic) IBOutlet UIImageView *reminderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reminderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagReminderConstraint;

@end
