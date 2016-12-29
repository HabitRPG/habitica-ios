//
//  HRPGLoginViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import "EAIntroView.h"
#import "AppAuth.h"

@interface HRPGLoginViewController
    : UITableViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,
                            FBSDKLoginButtonDelegate, EAIntroDelegate, UIWebViewDelegate, OIDAuthStateChangeDelegate>
@property BOOL hideCancelButton;
@property(weak, nonatomic) UITextField *usernameField;
@property(weak, nonatomic) UITextField *emailField;
@property(weak, nonatomic) UITextField *passwordField;
@property(weak, nonatomic) UITextField *repeatPasswordField;
@property(weak, nonatomic) UITableViewCell *loginCell;
@property(weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property(weak, nonatomic) UILabel *loginLabel;
@property(weak, nonatomic) UIButton *onePasswordButton;

@property BOOL isRootViewController;
@property BOOL shouldDismissOnNextAppear;
@end
