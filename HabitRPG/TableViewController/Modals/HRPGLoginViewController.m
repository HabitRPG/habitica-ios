//
//  HRPGLoginViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 19/01/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGLoginViewController.h"
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"
#import "OnePasswordExtension.h"
#import "HRPGTabBarController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MRProgress.h"
#import "CRToast.h"
#import <Google/Analytics.h>
#import "HRPGAvatarSetupViewController.h"

@interface HRPGLoginViewController ()
@property HRPGManager *sharedManager;
@property BOOL isRegistering;
@property FBSDKLoginButton *fbLoginButton;

@property UIView *headerView;
@property UIImageView *gryphonView;
@property UIImageView *logoView;

@end

@implementation HRPGLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.hideCancelButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;

    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    self.gryphonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gryphon"]];
    self.gryphonView.contentMode = UIViewContentModeCenter;
    self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text"]];
    self.logoView.contentMode = UIViewContentModeCenter;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    } else {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
    }
    [self.headerView addSubview:self.gryphonView];
    [self.headerView addSubview:self.logoView];

    self.tableView.tableHeaderView = self.headerView;
    
    [FBSDKLoginButton class];
}

- (void)viewWillLayoutSubviews {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.gryphonView.frame = CGRectMake(0, 20, self.view.frame.size.width, 85);
        self.logoView.frame = CGRectMake(0, 105, self.view.frame.size.width, 55);
        self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    } else {
        self.gryphonView.frame = CGRectMake(0, 0, self.view.frame.size.width, 85);
        self.logoView.frame = CGRectMake(0, 85, self.view.frame.size.width, 55);
        self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 140);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.isRegistering) {
            return 4;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 0) {
        return 65;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 30;
    } else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UsernameCell" forIndexPath:indexPath];
            self.usernameField = (UITextField*)[cell viewWithTag:1];
        } else if (self.isRegistering && indexPath.item == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EmailCell" forIndexPath:indexPath];
            self.emailField = (UITextField*)[cell viewWithTag:1];
        } else if (indexPath.item == 1 || indexPath.item == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
            self.passwordField = (UITextField*)[cell viewWithTag:1];
            self.onePasswordButton = (UIButton*)[cell viewWithTag:3];
            [self.onePasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
        } else if (self.isRegistering && indexPath.item == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatPasswordCell" forIndexPath:indexPath];
            self.repeatPasswordField = (UITextField*)[cell viewWithTag:1];
        }
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoginButtonCell" forIndexPath:indexPath];
        self.loginCell = cell;
        self.loginLabel = (UILabel*)[cell viewWithTag:1];
        self.activityIndicator = (UIActivityIndicatorView*)[cell viewWithTag:2];
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookButtonCell" forIndexPath:indexPath];
        self.fbLoginButton = (FBSDKLoginButton*)[cell viewWithTag:1];
        self.fbLoginButton.delegate = self;
    }
    
    UIView *wrapperView = [cell viewWithTag:9];
    if (wrapperView) {
        wrapperView.layer.cornerRadius = 5;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 0) {
        [self loginUser:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    }
    if (textField == self.passwordField) {
        [self loginUser:textField];
    }
    return YES;
}

- (IBAction)loginUser:(id)sender {
    if (self.isRegistering) {
        if (![self isEmailValid:self.emailField.text]) {
            self.navigationItem.prompt = NSLocalizedString(@"Invalid E-Mail Address.", nil);
            [self showLoginLabel];
            [self.emailField becomeFirstResponder];
            return;
        }
        if (![self.passwordField.text isEqualToString:self.repeatPasswordField.text]) {
            self.navigationItem.prompt = NSLocalizedString(@"Passwords don't match.", nil);
            [self showLoginLabel];
            [self.passwordField becomeFirstResponder];
            return;
        }
    }
    self.loginCell.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:0.5 animations:^() {
        self.loginLabel.alpha = 0.0;
        self.activityIndicator.alpha = 1.0;
    }];
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    if (self.isRegistering) {
        [self.emailField resignFirstResponder];
        [self.repeatPasswordField resignFirstResponder];

        [_sharedManager registerUser:self.usernameField.text withPassword:self.passwordField.text withEmail:self.emailField.text onSuccess:^() {
            [_sharedManager setCredentials];
            [_sharedManager fetchUser:^() {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldReloadAllData" object:nil];
                if (self.isRootViewController) {
                    User *user = [self.sharedManager getUser];
                    if ([user.lastSetupStep integerValue] != HRPGAvatarSetupStepsTasks) {
                        [self performSegueWithIdentifier:@"SetupSegue" sender:self];
                    } else {
                        [self performSegueWithIdentifier:@"MainSegue" sender:self];
                    }
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } onError:^() {
                if (self.isRootViewController) {
                    User *user = [self.sharedManager getUser];
                    if ([user.lastSetupStep integerValue] != HRPGAvatarSetupStepsTasks) {
                        [self performSegueWithIdentifier:@"SetupSegue" sender:self];
                    } else {
                        [self performSegueWithIdentifier:@"MainSegue" sender:self];
                    }
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }            }];
        } onError:^(NSString *errorMessage) {
            if ([errorMessage isEqualToString:@"Email already taken"]) {
                self.navigationItem.prompt = NSLocalizedString(@"Email already taken.", nil);
                [self.emailField becomeFirstResponder];
            } else if ([errorMessage isEqualToString:@"Username already taken"]) {
                self.navigationItem.prompt = NSLocalizedString(@"Username already taken.", nil);
                [self.usernameField becomeFirstResponder];
            } else {
                self.navigationItem.prompt = errorMessage;
            }
            [self showLoginLabel];
        }];
    } else {
        [_sharedManager loginUser:self.usernameField.text withPassword:self.passwordField.text onSuccess:^() {
            [self onSuccessfullLogin];
        } onError:^() {
            self.navigationItem.prompt = NSLocalizedString(@"Invalid username or password", nil);
            [self.usernameField becomeFirstResponder];
            [self showLoginLabel];
        }];
    }
}

- (IBAction)onePasswordButtonSelected:(id)sender {
    __weak typeof (self) miniMe = self;
    if (self.isRegistering) {
        NSDictionary *newLoginDetails = @{
                                          AppExtensionTitleKey: @"Habitica",
                                          AppExtensionUsernameKey: self.usernameField.text ? : @"",
                                          AppExtensionPasswordKey: self.passwordField.text ? : @"",
                                          AppExtensionNotesKey: @"Saved with Habitica",
                                          };
        NSDictionary *passwordGenerationOptions = @{
                                                    AppExtensionGeneratedPasswordMinLengthKey: @(16),
                                                    AppExtensionGeneratedPasswordMaxLengthKey: @(50)
                                                    };
        
        __weak typeof (self) miniMe = self;
        
        [[OnePasswordExtension sharedExtension] storeLoginForURLString:@"https://habitica.com/" loginDetails:newLoginDetails passwordGenerationOptions:passwordGenerationOptions forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {
            
            if (!loginDict) {
                if (error.code != AppExtensionErrorCodeCancelledByUser) {
                    NSLog(@"Failed to use 1Password App Extension to save a new Login: %@", error);
                }
                return;
            }
            
            __strong typeof(self) strongMe = miniMe;
            
            strongMe.usernameField.text = loginDict[AppExtensionUsernameKey] ? : @"";
            strongMe.passwordField.text = loginDict[AppExtensionPasswordKey] ? : @"";
            strongMe.repeatPasswordField.text = loginDict[AppExtensionPasswordKey] ? : @"";
        }];
    } else {
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"https://habitica.com/" forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {
        if (!loginDict) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }
        
        __strong typeof(self) strongMe = miniMe;
        strongMe.usernameField.text = loginDict[AppExtensionUsernameKey];
        strongMe.passwordField.text = loginDict[AppExtensionPasswordKey];
    }];
    }
}

- (IBAction)registerLoginSwitch:(id)sender {
    self.isRegistering = !self.isRegistering;
    if (self.isRegistering) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0], [NSIndexPath indexPathForItem:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Log in", nil);
        self.loginLabel.text = NSLocalizedString(@"Register", nil);
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0], [NSIndexPath indexPathForItem:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Register", nil);
        self.loginLabel.text = NSLocalizedString(@"Log in", nil);
    }
}

-(BOOL) isEmailValid:(NSString *)checkString
{
    NSString *emailRegex = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)showLoginLabel {
    self.loginCell.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^() {
        self.loginLabel.alpha = 1.0;
        self.activityIndicator.alpha = 0.0;
    }];
    [self.activityIndicator stopAnimating];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error) {
        NSDictionary *options = @{kCRToastTextKey : NSLocalizedString(@"Authentication Error", nil),
                                  kCRToastSubtitleTextKey : NSLocalizedString(@"There was an error with the authentication. Try again later", nil),
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                                  kCRToastSubtitleTextAlignmentKey : @(NSTextAlignmentLeft),
                                  kCRToastBackgroundColorKey : [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f],
                                  };
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                    }];
    } else if (result.isCancelled) {
        NSDictionary *options = @{kCRToastTextKey : NSLocalizedString(@"Authentication Cancelled", nil),
                                  kCRToastSubtitleTextKey : NSLocalizedString(@"The authentication process was cancelled.", nil),
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                                  kCRToastSubtitleTextAlignmentKey : @(NSTextAlignmentLeft),
                                  kCRToastBackgroundColorKey : [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f],
                                  };
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                    }];
    } else {
        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        [self.sharedManager loginUserSocial:[FBSDKAccessToken currentAccessToken].userID withAccessToken:[FBSDKAccessToken currentAccessToken].tokenString onSuccess:^() {
            overlayView.mode = MRProgressOverlayViewModeCheckmark;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [overlayView dismiss:YES];
            });
            [self onSuccessfullLogin];
        }onError:^() {
            
        }];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

- (void) onSuccessfullLogin {
    [_sharedManager setCredentials];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"behaviour"
                                                          action:@"login"
                                                           label:nil
                                                           value:nil] build]];
    
    [_sharedManager fetchUser:^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldReloadAllData" object:nil];
        if (self.isRootViewController) {
            [self performSegueWithIdentifier:@"MainSegue" sender:self];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }                 onError:^() {
        if (self.isRootViewController) {
            [self performSegueWithIdentifier:@"MainSegue" sender:self];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SetupSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        HRPGAvatarSetupViewController *avatarSetupViewController = (HRPGAvatarSetupViewController*)navController.topViewController;
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        HRPGManager *manager = appdelegate.sharedManager;
        User *user = [manager getUser];
        avatarSetupViewController.lastCompletedStep = [user.lastSetupStep integerValue];
        avatarSetupViewController.user = user;
        avatarSetupViewController.managedObjectContext = manager.getManagedObjectContext;
    }
}

@end
