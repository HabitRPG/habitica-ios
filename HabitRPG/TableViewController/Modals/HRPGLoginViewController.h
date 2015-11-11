//
//  HRPGLoginViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "EAIntroView.h"

@interface HRPGLoginViewController : UITableViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, FBSDKLoginButtonDelegate, EAIntroDelegate>
@property BOOL hideCancelButton;
@property(weak, nonatomic) UITextField *usernameField;
@property(weak, nonatomic) UITextField *emailField;
@property(weak, nonatomic) UITextField *passwordField;
@property(weak, nonatomic) UITextField *repeatPasswordField;
@property(weak, nonatomic) UITableViewCell *loginCell;
@property(weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property(weak, nonatomic) UILabel *loginLabel;
@property (weak, nonatomic) UIButton *onePasswordButton;

@property BOOL isRootViewController;
@property BOOL shouldDismissOnNextAppear;
@end
