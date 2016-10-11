//
//  HRPGSpellTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spell.h"

@interface HRPGSpellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *spellImageView;

- (void) configureForSpell:(Spell *)spell withMagic:(NSNumber *)magic withOwned:(NSNumber *)owned;

@end
