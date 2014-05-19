//
//  HRPGSpellTabBarController.h
//  RabbitRPG
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spell.h"

@interface HRPGSpellTabBarController : UITabBarController

@property Spell *spell;
@property NSString *taskID;
@property UITableView *sourceTableView;
-(void)castSpell;

@end
