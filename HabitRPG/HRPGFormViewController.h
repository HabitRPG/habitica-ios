//
//  HRPGAddViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
@interface HRPGFormViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property NSString *taskType;
@property Task *task;
@property BOOL editTask;
@end
