//
//  ShortdiaryLoginViewController.m
//  Shortdiary
//
//  Created by Phillip Thelen on 19/01/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGLoginViewController.h"
#import <CRToast.h>
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"

@interface HRPGLoginViewController ()
@property HRPGManager *sharedManager;
@end

@implementation HRPGLoginViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.hideCancelButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    _sharedManager = appdelegate.sharedManager;
    
    [self.usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.item == 0) {
        [self loginUser:0];
    }
}

- (IBAction)loginUser:(id)sender {
    self.loginCell.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^() {
        self.loginLabel.alpha = 0.0;
        self.activityIndicator.alpha = 1.0;
    }];
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [_sharedManager loginUser:self.usernameField.text withPassword:self.passwordField.text onSuccess:^() {
        [_sharedManager setCredentials];
        [self dismissViewControllerAnimated:YES completion:nil];
    } onError:^() {
        self.navigationItem.prompt = NSLocalizedString(@"Invalid username or password", nil);
        [self.usernameField becomeFirstResponder];
        self.loginCell.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.5 animations:^() {
            self.loginLabel.alpha = 1.0;
            self.activityIndicator.alpha = 0.0;
        }];
    }];
    
}
@end
