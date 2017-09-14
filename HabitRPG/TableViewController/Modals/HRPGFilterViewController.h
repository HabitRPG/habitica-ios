//
//  HRPGTagViewController.h
//  Habitica
//
//  Created by Phillip on 08/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGBaseViewController.h"

@interface HRPGFilterViewController : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(nonatomic) NSMutableArray *selectedTags;
@property(nonatomic) NSString *taskType;

@end
