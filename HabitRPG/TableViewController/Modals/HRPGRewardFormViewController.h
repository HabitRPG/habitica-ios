//
//  HRPGRewardFormViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 21/04/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reward.h"
#import "XLFormViewController.h"


@interface HRPGRewardFormViewController : XLFormViewController

@property(weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property Reward *reward;
@property BOOL editReward;

@end
