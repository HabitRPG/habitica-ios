//
//  HRPGCustomizationsOverviewController.h
//  Habitica
//
//  Created by Phillip Thelen on 01/05/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGCustomizationsOverviewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
