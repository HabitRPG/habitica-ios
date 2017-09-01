//
//  HRPGPartyMembersTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 22/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGPartyMembersViewController
    : HRPGBaseViewController

@property BOOL isLeader;
@property NSString *partyID;

@end
