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
}

- (void)configureForItem:(ChecklistItem *)item forTask:(Task *)task {
    [super configureForItem:item forTask:task];
}

@end
