//
//  HRPGTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGProfileViewController : HRPGBaseViewController<NSFetchedResultsControllerDelegate,
                                                              MFMailComposeViewControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
