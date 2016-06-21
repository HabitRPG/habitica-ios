//
//  HRPGQuestGroupTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 12/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGGroupTableViewController.h"
#import "Quest.h"

@interface HRPGQuestGroupTableViewController : HRPGGroupTableViewController

@property(nonatomic) Quest *quest;

- (void)reloadQuest;

- (bool)canInviteToQuest;

- (bool)displayQuestSection;
- (bool)isQuestSection:(NSInteger)section;
@end
