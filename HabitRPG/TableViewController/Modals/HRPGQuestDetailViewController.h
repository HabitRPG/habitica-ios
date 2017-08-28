//
//  HRPGQuestInvitationViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HRPGBaseViewController.h"
#import "Quest+CoreDataClass.h"
#import "User.h"

@interface HRPGQuestDetailViewController : HRPGBaseViewController<UIAlertViewDelegate>

@property Quest *quest;
@property Group *group;
@property User *user;
@property UIViewController *sourceViewcontroller;
@property NSNumber *hideAskLater;
@property NSNumber *wasPushed;
@property NSNumber *isWorldQuest;
@end
