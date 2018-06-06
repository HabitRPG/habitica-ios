//
//  HRPGAboutViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 12/04/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGAboutViewController.h"
#import "VTAcknowledgementsViewController.h"
#import <sys/utsname.h>
#import "Habitica-Swift.h"
#import <Instabug/Instabug.h>

@interface HRPGAboutViewController ()

@property UIView *headerView;
@property NSIndexPath *selectedIndex;
@property NSString *supportEmail;

@end

@implementation HRPGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;

    self.headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    UIImageView *headerImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake((self.view.frame.size.width - 130) / 2, 10, 130, 130)];
    headerImageView.image = [UIImage imageNamed:@"Logo"];
    [self.headerView addSubview:headerImageView];

    self.tableView.tableHeaderView = self.headerView;
    
    ConfigRepository *configRepository = [[ConfigRepository alloc] init];
    self.supportEmail = [configRepository stringWithVariable:ConfigVariableSupportEmail];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = @"BasicCell";
    if (indexPath.item == 0 || indexPath.item == 3 || indexPath.item == 7) {
        cellName = @"RightDetailCell";
    }
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (indexPath.item == 0) {
        cell.textLabel.text = NSLocalizedString(@"Website", nil);
        cell.detailTextLabel.text = @"habitica.com";
    } else if (indexPath.item == 1) {
        cell.textLabel.text = NSLocalizedString(@"Send feedback", nil);
    } else if (indexPath.item == 2) {
        cell.textLabel.text = NSLocalizedString(@"Report a bug", nil);
    } else if (indexPath.item == 3) {
        cell.textLabel.text = @"Twitter";
        cell.detailTextLabel.text = @"@habitica";
    } else if (indexPath.item == 4) {
        cell.textLabel.text = NSLocalizedString(@"Leave a Review", nil);
    } else if (indexPath.item == 5) {
        cell.textLabel.text = NSLocalizedString(@"View Source Code", nil);
    } else if (indexPath.item == 6) {
        cell.textLabel.text = NSLocalizedString(@"Acknowledgements", nil);
    } else if (indexPath.item == 7) {
        cell.textLabel.text = NSLocalizedString(@"Version", nil);
        NSString *appVersionString = [NSString
            stringWithFormat:@"%@ (%@)",
                             [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                             [[NSBundle mainBundle]
                                 objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
        cell.detailTextLabel.text = appVersionString;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    switch (indexPath.item) {
        case 0: {
            [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:@"https://habitica.com/"]];
            break;
        }
        case 1: {
            if ([HabiticaAppDelegate isRunningLive]) {
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *composeViewController =
                    [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                    [composeViewController setMailComposeDelegate:self];
                    [composeViewController setToRecipients:@[ self.supportEmail ] ];
                    [composeViewController setSubject:@"[iOS] Feedback"];
                    [self presentViewController:composeViewController animated:YES completion:nil];
                } else {
                    [self showNoEmailAlert];
                }
            } else {
                [Instabug invokeWithInvocationMode:IBGInvocationModeNewFeedback];
            }
            
            break;
        }
        case 2: {
            if ([HabiticaAppDelegate isRunningLive]) {
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *composeViewController =
                    [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                    [composeViewController setMailComposeDelegate:self];
                    [composeViewController setToRecipients:@[ self.supportEmail ]];
                    [composeViewController setSubject:@"[iOS] Bugreport"];
                    [composeViewController setMessageBody:[self createDeviceInformationString]
                                                   isHTML:NO];
                    [self presentViewController:composeViewController animated:YES completion:nil];
                } else {
                    [self showNoEmailAlert];
                }
            } else {
                [Instabug invokeWithInvocationMode:IBGInvocationModeNewBug];
            }
            break;
        }
        case 3: {
            [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:@"https://twitter.com/habitica"]];
            break;
        }
        case 4: {
            [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id994882113"]];
            break;
        }
        case 5: {
            [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:@"https://github.com/HabitRPG/habitrpg-ios/"]];
            break;
        }
        case 6: {
            VTAcknowledgementsViewController *viewController =
                [VTAcknowledgementsViewController acknowledgementsViewController];
            viewController.headerText = NSLocalizedString(@"We love open source software.", nil);

            if (self.topHeaderNavigationController) {
                [viewController.tableView
                    setContentInset:UIEdgeInsetsMake(self.topHeaderNavigationController.contentInset, 0, 0,
                                                     0)];
                viewController.tableView.scrollIndicatorInsets =
                    UIEdgeInsetsMake(self.topHeaderNavigationController.contentInset, 0, 0, 0);
                if (self.topHeaderNavigationController.state == TopHeaderStateHidden) {
                    [viewController.tableView
                        setContentOffset:CGPointMake(0,
                                                     self.tableView.contentInset.top - self.topHeaderNavigationController.contentOffset)];
                }
            }

            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    // Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
}

- (NSString *)createDeviceInformationString {
    NSMutableString *informationString =
        [@"Please describe the bug you encountered:\n\n\n\n\n\n\n\n\n\n\n\n" mutableCopy];

    [informationString
        appendString:NSLocalizedString(@"The following lines help us find and squash the Bug you "
                                       @"encountered. Please do not delete/change them.\n",
                                       nil)];

    [informationString
        appendString:[NSString stringWithFormat:@"iOS Version: %@\n",
                                                [[UIDevice currentDevice] systemVersion]]];
    struct utsname systemInfo;
    uname(&systemInfo);
    [informationString
        appendString:[NSString stringWithFormat:@"Device: %@\n",
                                                [NSString stringWithCString:systemInfo.machine
                                                                   encoding:NSUTF8StringEncoding]]];
    [informationString
        appendString:[NSString stringWithFormat:@"App Version: %@\n",
                                                [[NSBundle mainBundle] infoDictionary]
                                                    [@"CFBundleShortVersionString"]]];
    [informationString appendString:[NSString stringWithFormat:@"User UUID: %@\n",
                                                               [[AuthenticationManager shared] currentUserId]]];

    return informationString;
}

- (void)showNoEmailAlert {
    HabiticaAlertController *alert = [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Your email isn't set up yet", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Whoops, looks like you haven't set up your email on this phone yet. Configure an account in the iOS mail app to use this quick-reporting option, or just email us directly at mobile@habitica.com", nil), self.supportEmail]];
    [alert addCloseActionWithHandler:nil];
    [alert show];
}

@end
