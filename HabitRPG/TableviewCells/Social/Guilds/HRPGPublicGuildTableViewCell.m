//
//  HRPGPublicGuildTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 05/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGPublicGuildTableViewCell.h"
#import "UIColor+Habitica.h"
#import "NSString+Emoji.h"

@interface HRPGPublicGuildTableViewCell ()

@property bool isMember;

@end

@implementation HRPGPublicGuildTableViewCell

- (void)configureForGuild:(Group *)guild {
    self.titleLabel.text = [guild.name stringByReplacingEmojiCheatCodesWithUnicode];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.descriptionLabel.text = guild.hdescription;
    self.descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.memberCountLabel.text =
        [NSString stringWithFormat:NSLocalizedString(@"%@ Members", nil), guild.memberCount];
    self.memberCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    if ([guild.isMember boolValue]) {
        self.joinLeaveButton.backgroundColor = [UIColor red10];
        [self.joinLeaveButton setTitle:NSLocalizedString(@"Leave", nil)
                              forState:UIControlStateNormal];
    } else {
        self.joinLeaveButton.backgroundColor = [UIColor green10];
        [self.joinLeaveButton setTitle:NSLocalizedString(@"Join", nil)
                              forState:UIControlStateNormal];
    }
    self.isMember = guild.isMember;
    self.joinLeaveButton.layer.cornerRadius = 5;
    self.joinLeaveButtonWidthConstraint.constant =
        self.joinLeaveButton.intrinsicContentSize.width + 20;

    [self setNeedsLayout];
}

- (IBAction)joinLeaveButtonTapped:(id)sender {
    if (self.isMember) {
        if (self.leaveAction) {
            self.leaveAction();
        }
    } else {
        if (self.joinAction) {
            self.joinAction();
        }
    }
}

@end
