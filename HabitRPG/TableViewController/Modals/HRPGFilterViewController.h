//
//  HRPGTagViewController.h
//  Habitica
//
//  Created by Phillip on 08/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"

@interface HRPGFilterViewController : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

@property(nonatomic) NSMutableArray *selectedTags;
@property(nonatomic) NSString *taskType;

@end
