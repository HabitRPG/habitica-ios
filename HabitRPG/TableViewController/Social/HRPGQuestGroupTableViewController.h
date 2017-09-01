//
//  HRPGQuestGroupTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 12/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGGroupTableViewController.h"
#import "Quest+CoreDataClass.h"

@interface HRPGQuestGroupTableViewController : HRPGGroupTableViewController

@property(nonatomic) Quest *quest;

- (void)reloadQuest;

- (bool)canInviteToQuest;

- (bool)displayQuestSection;
- (bool)isQuestSection:(NSInteger)section;
@end
