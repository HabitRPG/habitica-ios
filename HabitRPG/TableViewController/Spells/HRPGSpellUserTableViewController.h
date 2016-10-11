//
//  HRPGSpellUserTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 11/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"
#import "Spell.h"

@interface HRPGSpellUserTableViewController : HRPGBaseViewController

@property Spell *spell;
@property NSString *userID;

@end
