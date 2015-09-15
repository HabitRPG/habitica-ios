//
//  HRPGCheckedTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCheckedTableViewCell.h"
#import "UIColor+Habitica.h"
#import "NSString+Emoji.h"

@implementation HRPGCheckedTableViewCell

- (void)configureForTask:(Task *)task {
    [super configureForTask:task];
    [self.checkBox configureForTask:task];
    self.checklistIndicator.backgroundColor = [task lightTaskColor];
    self.checklistIndicator.hidden = NO;

    NSNumber *checklistCount = [task valueForKeyPath:@"checklist.@count"];
    if ([checklistCount integerValue] > 0) {
        int checkedCount = 0;
        for (ChecklistItem *item in [task checklist]) {
            if ([item.completed boolValue]) {
                checkedCount++;
            }
        }
        self.checklistDoneLabel.text = [[NSNumber numberWithInt:checkedCount] stringValue];
        self.checklistAllLabel.text = [checklistCount stringValue];
        if (checkedCount == [checklistCount integerValue]) {
            self.checklistIndicator.backgroundColor = [UIColor gray100];
        }
        self.checklistDoneLabel.hidden = NO;
        self.checklistAllLabel.hidden = NO;
        self.checklistSeparator.hidden = NO;
        self.checklistIndicatorWidth.constant = 37.0;
    } else {
        self.checklistDoneLabel.hidden = YES;
        self.checklistAllLabel.hidden = YES;
        self.checklistSeparator.hidden = YES;
        self.checklistIndicatorWidth.constant = 6.0;
    }
    
    if ([task.completed boolValue]) {
        self.backgroundColor = [UIColor gray500];
        self.checklistIndicator.backgroundColor = [UIColor gray100];
        self.titleLabel.textColor = [UIColor gray50];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

- (void)configureForItem:(ChecklistItem *)item forTask:(Task *)task{
    self.titleLabel.text = [item.text stringByReplacingEmojiCheatCodesWithUnicode];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.checkBox configureForChecklistItem:item forTask:task];
    self.checklistIndicator.hidden = YES;
    self.subtitleLabel.text = nil;
    self.titleNoteConstraint.constant = 0;
}

@end
