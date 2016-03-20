//
//  HRPGTaskTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTaskTableViewCell.h"
#import "Task.h"
#import "NSString+Emoji.h"
#import "UIColor+Habitica.h"

@implementation HRPGTaskTableViewCell

- (void)configureForTask:(Task *)task {
    self.titleLabel.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.titleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.textColor = [UIColor gray50];

    NSString *trimmedNotes =
        [task.notes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (trimmedNotes && trimmedNotes.length != 0) {
        self.subtitleLabel.text = [trimmedNotes stringByReplacingEmojiCheatCodesWithUnicode];
        self.subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        self.titleNoteConstraint.constant = 6.0;
    } else {
        self.subtitleLabel.text = nil;
        self.titleNoteConstraint.constant = 0;
    }

    if (task.tags != nil && task.tags.count > 0) {
        self.tagImageView.hidden = NO;
        self.tagImageViewHeightConstraint.constant = 18.0f;
    } else {
        self.tagImageView.hidden = YES;
        self.tagImageViewHeightConstraint.constant = 0;
    }

    if (task.reminders != nil && task.reminders.count > 0) {
        self.reminderImageView.hidden = NO;
        self.reminderImageViewHeightConstraint.constant = 18.0f;
    } else {
        self.reminderImageView.hidden = YES;
        self.reminderImageViewHeightConstraint.constant = 0;
    }

    if (self.reminderImageView.hidden || self.tagImageView.hidden) {
        self.tagReminderConstraint.constant = 0;
    } else {
        self.tagReminderConstraint.constant = 4.0f;
    }

    [self setNeedsLayout];
}

@end
