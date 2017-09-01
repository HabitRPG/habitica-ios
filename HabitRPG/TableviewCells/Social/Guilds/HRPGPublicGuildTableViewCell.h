//
//  HRPGPublicGuildTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 05/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface HRPGPublicGuildTableViewCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *memberCountLabel;
@property(weak, nonatomic) IBOutlet UIButton *joinLeaveButton;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *joinLeaveButtonWidthConstraint;
@property(weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)configureForGuild:(Group *)guild;

@property(nonatomic, copy) void (^joinAction)();
@property(nonatomic, copy) void (^leaveAction)();

@end
