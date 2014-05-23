//
//  HRPGLoginViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGLoginViewController : UITableViewController <UITextFieldDelegate>
@property BOOL hideCancelButton;
@property(weak, nonatomic) IBOutlet UITextField *usernameField;
@property(weak, nonatomic) IBOutlet UITextField *passwordField;
@property(weak, nonatomic) IBOutlet UITableViewCell *loginCell;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(weak, nonatomic) IBOutlet UILabel *loginLabel;

@end
