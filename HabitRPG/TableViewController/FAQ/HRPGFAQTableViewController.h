//
//  HRPGFAQTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGFAQTableViewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
