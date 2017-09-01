//
//  HRPGRewardsTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 26/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGEquipmentViewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
