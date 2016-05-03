//
//  HRPGTaskSetupTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 02/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGAvatarSetupViewController.h"
#import "User.h"

@interface HRPGTaskSetupTableViewController
    : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property NSInteger currentStep;
@property User *user;
@property NSManagedObjectContext *managedObjectContext;

@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(weak, nonatomic) IBOutlet UIButton *skipButton;
@property(weak, nonatomic) IBOutlet UIButton *backButton;
@property(weak, nonatomic) IBOutlet UIButton *nextButton;
@property BOOL shouldDismiss;

@end
