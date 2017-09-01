//
//  HRPGSpellTabBarController.h
//  Habitica
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spell.h"

@interface HRPGSpellTabBarController : UITabBarController

@property Spell *spell;
@property NSString *taskID;
@property UITableView *sourceTableView;

- (void)castSpell;

@end
