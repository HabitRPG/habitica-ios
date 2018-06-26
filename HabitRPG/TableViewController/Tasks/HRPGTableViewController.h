//
//  HRPGTableViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@protocol TaskTableViewDataSourceProtocol;

@interface HRPGTableViewController : HRPGBaseViewController
@property id<TaskTableViewDataSourceProtocol> dataSource;

- (void)refresh;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue;

- (UIView *)viewWithIcon:(UIImage *)image;

- (NSPredicate *)getPredicate;

- (void)scrollToTaskWithId:(NSString *)taskID;

@property NSInteger filterType;

@property NSString *scrollToTaskAfterLoading;

- (void)didChangeFilter:(NSNotification *)notification;

@end
