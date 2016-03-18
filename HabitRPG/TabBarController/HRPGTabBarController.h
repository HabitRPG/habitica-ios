//
//  HRPGTabBarController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"

@interface HRPGTabBarController : UITabBarController<NSFetchedResultsControllerDelegate>

@property NSArray *selectedTags;
@property(nonatomic) HRPGManager *sharedManager;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
