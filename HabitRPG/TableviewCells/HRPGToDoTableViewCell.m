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
    [self.checkBox configureForTask:task];

    self.dueLabel.backgroundColor = self.backgroundColor;
}

- (void)configureForItem:(ChecklistItem *)item forTask:(Task *)task {
    [super configureForItem:item forTask:task];
    self.dueLabel.text = nil;
    self.notesDueSeparator.constant = 0;
}

@end
