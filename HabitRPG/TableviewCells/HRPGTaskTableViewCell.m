//
//  HRPGTaskTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTaskTableViewCell.h"
#import "NSString+Emoji.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

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

    [self.taskDetailLine configureWithTask:task];
    if (self.taskDetailLine.hasContent) {
        self.taskDetailLine.hidden = NO;
        self.taskDetailSpacing.constant = 4;
    } else {
        self.taskDetailLine.hidden = YES;
        self.taskDetailSpacing.constant = 0;
    }
    
    [self setNeedsLayout];
}

@end
