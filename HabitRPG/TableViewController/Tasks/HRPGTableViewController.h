//
//  HRPGTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGTableViewController : HRPGBaseViewController<NSFetchedResultsControllerDelegate>

- (void)refresh;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue;

- (UIView *)viewWithIcon:(UIImage *)image;

- (Task *)taskAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForTaskWithOffset:(NSIndexPath *)indexPath;

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (NSPredicate *)getPredicate;

- (void)scrollToTaskWithId:(NSString *)taskID;

@property NSInteger filterType;
@property NSInteger dayStart;

@property NSString *scrollToTaskAfterLoading;

- (void)didChangeFilter:(NSNotification *)notification;

@end
