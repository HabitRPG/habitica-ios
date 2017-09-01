//
//  HRPGTabBarController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"

@interface HRPGTabBarController : UITabBarController<NSFetchedResultsControllerDelegate>

@property NSArray *selectedTags;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
