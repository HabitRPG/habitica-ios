//
//  HRPGPublicGuildTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGPublicGuildTableViewCell.h"
#import "Group.h"
#import "UIColor+Habitica.h"

@implementation HRPGPublicGuildTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureForGuild:(Group *)guild {
    self.titleLabel.text = guild.name;
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.descriptionLabel.text = guild.hdescription;
    self.descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.memberCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Members", nil), guild.memberCount];
    self.memberCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    if ([guild.isMember boolValue]) {
        self.joinLeaveButton.backgroundColor = [UIColor red10];
        [self.joinLeaveButton setTitle:NSLocalizedString(@"Leave", nil) forState:UIControlStateNormal];
    } else {
        self.joinLeaveButton.backgroundColor = [UIColor green10];
        [self.joinLeaveButton setTitle:NSLocalizedString(@"Join", nil) forState:UIControlStateNormal];
    }
    self.joinLeaveButton.layer.cornerRadius = 5;
    self.joinLeaveButtonWidthConstraint.constant = self.joinLeaveButton.intrinsicContentSize.width + 20;
    
    [self setNeedsLayout];
}

@end
