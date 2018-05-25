//
//  HRPGSpellTaskController.h
//  Habitica
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGSpellTaskController : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSString *taskType;
@end
