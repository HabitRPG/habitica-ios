//
//  HRPGSpellTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGSpellTableViewCell.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGSpellTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownedLabel;

@property (weak, nonatomic) IBOutlet UIView *buyButton;
@property (weak, nonatomic) IBOutlet UIView *buyButtonBorderView;
@property (weak, nonatomic) IBOutlet UIImageView *buyButtonIconView;
@property (weak, nonatomic) IBOutlet UILabel *buyButtonLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buyButtonIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buyButtonIconLabelSpacing;

@end

@implementation HRPGSpellTableViewCell

- (void)configureForSpell:(Spell *)spell withMagic:(NSNumber *)magic withOwned:(NSNumber *)owned {
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.notesLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.ownedLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.buyButtonLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.titleLabel.text = spell.text;
    self.notesLabel.text = spell.notes;
    self.ownedLabel.text = nil;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.titleLabel.textColor = [UIColor darkTextColor];
    self.notesLabel.textColor = [UIColor darkTextColor];
    self.buyButtonLabel.textColor = [UIColor darkTextColor];
    self.buyButtonBorderView.layer.borderColor = [[UIColor purple400] CGColor];
    self.buyButtonIconWidth.constant = 8;
    self.buyButtonIconLabelSpacing.constant = 4;
    if ([spell.klass isEqualToString:@"special"]) {
        self.buyButtonLabel.text = NSLocalizedString(@"USE", nil);
        self.ownedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Owned: %@", nil), [owned stringValue]];
        self.buyButtonIconView.image = nil;
        self.buyButtonIconWidth.constant = 0;
        self.buyButtonIconLabelSpacing.constant = 0;
    } else {
        self.buyButtonLabel.text = [spell.mana stringValue];
        self.buyButtonIconView.image = HabiticaIcons.imageOfMagic;
        if ([magic integerValue] < [spell.mana integerValue]) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.titleLabel.textColor = [UIColor lightGrayColor];
            self.notesLabel.textColor = [UIColor lightGrayColor];
            self.buyButtonLabel.textColor = [UIColor lightGrayColor];
            self.buyButtonBorderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        }
    }

}

@end
