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
#import "User.h"
#import "HRPGBaseViewController.h"

@interface HRPGQuestDetailViewController : HRPGBaseViewController <UIAlertViewDelegate>

@property Quest *quest;
@property Group *party;
@property User *user;
@property UIViewController *sourceViewcontroller;
@property NSNumber *hideAskLater;
@property NSNumber *wasPushed;
@property NSNumber *isWorldQuest;
@end
