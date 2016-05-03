//
//  HRPGQuestParticipantsViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HRPGBaseViewController.h"
#import "Quest.h"

@interface HRPGQuestParticipantsViewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property Quest *quest;
@property Group *group;
@end
