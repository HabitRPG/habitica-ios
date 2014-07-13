//
//  HRPGUserProfileViewController.h
//  RabbitRPG
//
//  Created by Phillip on 13/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGUserProfileViewController : HRPGBaseViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property NSString *userID;
@property NSString *username;

@end
