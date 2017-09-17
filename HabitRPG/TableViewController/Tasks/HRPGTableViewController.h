//
//  HRPGTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"
#import <RBQFetchedResultsController/RBQFetchedResultsController.h>
#import <RBQFetchedResultsController/RBQFetchRequest.h>

@interface HRPGTableViewController : HRPGBaseViewController<RBQFetchedResultsControllerDelegate>

- (void)refresh;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue;

- (UIView *)viewWithIcon:(UIImage *)image;

- (Task *)taskAtIndexPath:(NSIndexPath *)indexPath;

@property(strong, nonatomic) RBQFetchedResultsController *fetchedResultsController;
- (NSPredicate *)getPredicate;

- (void)scrollToTaskWithId:(NSString *)taskID;

@property NSInteger filterType;
@property NSInteger dayStart;

@property NSString *scrollToTaskAfterLoading;

- (void)didChangeFilter:(NSNotification *)notification;

@end
