//
//  HRPGInboxTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGInboxTableViewController : HRPGBaseViewController<NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
