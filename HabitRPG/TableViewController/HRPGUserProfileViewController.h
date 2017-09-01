//
//  HRPGUserProfileViewController.h
//  Habitica
//
//  Created by Phillip on 13/07/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGUserProfileViewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property NSString *userID;
@property NSString *username;

@end
