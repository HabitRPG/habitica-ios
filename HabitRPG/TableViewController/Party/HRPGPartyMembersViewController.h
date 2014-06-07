//
//  HRPGPartyMembersTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 22/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGPartyMembersViewController : HRPGBaseViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
