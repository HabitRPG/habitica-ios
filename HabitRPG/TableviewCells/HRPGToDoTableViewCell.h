//
//  HRPGToDoTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCheckedTableViewCell.h"

@interface HRPGToDoTableViewCell : HRPGCheckedTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notesDueSeparator;

@property NSDateFormatter *dateFormatter;

@end
