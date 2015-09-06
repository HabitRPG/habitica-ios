//
//  HRPGDailyTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCheckedTableViewCell.h"

@interface HRPGDailyTableViewCell : HRPGCheckedTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *streakLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notesStreakSeparator;

- (void)configureForTask:(Task *) task withOffset:(NSInteger) offset;

@end
