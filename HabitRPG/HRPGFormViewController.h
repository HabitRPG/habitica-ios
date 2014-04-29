//
//  HRPGAddViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "HRPGBaseViewController.h"
@interface HRPGFormViewController : HRPGBaseViewController <UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property NSString *taskType;
@property Task *task;
@property BOOL editTask;
@end
