//
//  HRPGToDoTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGToDoTableViewCell.h"
#import "UIColor+Habitica.h"

@implementation HRPGToDoTableViewCell

- (void)configureForTask:(Task *)task {
    [super configureForTask:task];
    
    if (task.duedate) {
        self.dueLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        self.notesDueSeparator.constant = 6.0;

        NSDate *now = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        [components setHour:0];
        NSDate *today = [calendar dateFromComponents:components];
        if ([task.duedate compare:today] == NSOrderedAscending) {
            self.dueLabel.textColor = [UIColor red10];
            self.dueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due %@", nil), [self.dateFormatter stringFromDate:task.duedate]];
        } else {
            self.dueLabel.textColor = [UIColor gray50];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *differenceValue = [calendar components:NSCalendarUnitDay
                                                            fromDate:today toDate:task.duedate options:0];
            if ([differenceValue day] < 7) {
                if ([differenceValue day] == 0) {
                    self.dueLabel.textColor = [UIColor red10];
                    self.dueLabel.text = NSLocalizedString(@"Due today", nil);
                } else if ([differenceValue day] == 1) {
                    self.dueLabel.text = NSLocalizedString(@"Due tomorrow", nil);
                } else {
                    self.dueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due in %d days", nil), [differenceValue day]];
                }
            } else {
                self.dueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due %@", nil), [self.dateFormatter stringFromDate:task.duedate]];
            }
        }
    } else {
        self.dueLabel.text = nil;
        self.notesDueSeparator.constant = 0;
    }
    
}

- (void)configureForItem:(ChecklistItem *)item forTask:(Task *)task {
    [super configureForItem:item forTask:task];
    self.dueLabel.text = nil;
    self.notesDueSeparator.constant = 0;
}

@end
