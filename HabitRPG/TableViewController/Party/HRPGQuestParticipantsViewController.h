//
//  HRPGQuestParticipantsViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HRPGBaseViewController.h"
#import "Quest+CoreDataClass.h"

@interface HRPGQuestParticipantsViewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property Quest *quest;
@property Group *group;
@end
