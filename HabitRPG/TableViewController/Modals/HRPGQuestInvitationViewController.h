//
//  HRPGQuestInvitationViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quest.h"
#import "Group.h"

@interface HRPGQuestInvitationViewController : UITableViewController

@property Quest *quest;
@property Group *party;
@property UIViewController *sourceViewcontroller;
@end
