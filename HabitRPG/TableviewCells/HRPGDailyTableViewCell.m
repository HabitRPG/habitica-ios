//
//  HRPGDailyTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGDailyTableViewCell.h"
#import "UIColor+Habitica.h"

@implementation HRPGDailyTableViewCell

- (void)configureForTask:(Task *)task withOffset:(NSInteger)offset {
    [super configureForTask:task];
    [self.checkBox configureForTask:task withOffset:offset];
    if (![task.completed boolValue]) {
        if ([task dueTodayWithOffset:offset]) {
            self.titleLabel.textColor = [UIColor blackColor];
        } else {
            self.titleLabel.textColor = [UIColor darkGrayColor];
            self.checklistIndicator.backgroundColor = [UIColor gray100];
        }
    }
    if ([task.streak integerValue] > 0) {
        self.streakLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Current streak: %@", nil), task.streak];
        self.streakLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        self.notesStreakSeparator.constant = 6.0;
    } else {
        self.streakLabel.text = nil;
        self.notesStreakSeparator.constant = 0;
    }
}

- (void)configureForItem:(ChecklistItem *)item forTask:(Task *)task {
    [super configureForItem:item forTask:task];
    self.streakLabel.text = nil;
    self.notesStreakSeparator.constant = 0;
}

@end
