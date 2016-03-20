//
//  HRPGTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface HRPGProfileViewController : HRPGBaseViewController<NSFetchedResultsControllerDelegate,
                                                              MFMailComposeViewControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
