//
//  HRPGTavernViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGTavernViewController : HRPGBaseViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
