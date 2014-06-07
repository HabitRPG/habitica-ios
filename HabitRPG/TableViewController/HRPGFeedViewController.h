//
//  HRPGFeedViewController.h
//  RabbitRPG
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "Food.h"

@interface HRPGFeedViewController : HRPGBaseViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic) Food *selectedFood;

@end
