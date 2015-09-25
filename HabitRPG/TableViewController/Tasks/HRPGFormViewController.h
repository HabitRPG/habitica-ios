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
#import "XLFormViewController.h"

@interface HRPGFormViewController : XLFormViewController

@property(weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSString *taskType;
@property NSString *readableTaskType;
@property Task *task;
@property (nonatomic) BOOL editTask;
@property NSArray *activeTags;
@end
