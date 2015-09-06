//
//  HRPGAboutViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 12/04/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAboutViewController.h"
#import "HRPGManager.h"
#import "HRPGTopHeaderNavigationController.h"
#import <MessageUI/MessageUI.h>
#import <sys/utsname.h> 
#import <VTAcknowledgementsViewController.h>

@interface HRPGAboutViewController ()

@property UIView *headerView;
@property NSIndexPath *selectedIndex;

@end

@implementation HRPGAboutViewController

- (void)viewDidLoad {
    self.hidesTopBar = YES;
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-130)/2, 10, 130, 130)];
    headerImageView.image = [UIImage imageNamed:@"Logo"];
    [self.headerView addSubview:headerImageView];
    
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = @"BasicCell";
    if (indexPath.item == 0 || indexPath.item == 3 || indexPath.item == 8) {
        cellName = @"RightDetailCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    
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
        cell.textLabel.text = NSLocalizedString(@"FAQ", nil);
    } else if (indexPath.item == 5) {
        cell.textLabel.text = NSLocalizedString(@"Leave a Review", nil);
    } else if (indexPath.item == 6) {
        cell.textLabel.text = NSLocalizedString(@"View Source Code", nil);
    } else if (indexPath.item == 7) {
        cell.textLabel.text = NSLocalizedString(@"Acknowledgements", nil);
    } else if (indexPath.item == 8) {
        cell.textLabel.text = NSLocalizedString(@"Version", nil);
        NSString * appVersionString = [NSString stringWithFormat: @"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]];
        cell.detailTextLabel.text = appVersionString;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    switch (indexPath.item) {
        case 0: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://habitica.com/"]];
            break;
        }
        case 1: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[@"mobile@habitica.com"]];
                [composeViewController setSubject:@"[iOS] Feedback"];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
            break;
        }
        case 2: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[@"mobile@habitica.com"]];
                [composeViewController setSubject:@"[iOS] Bugreport"];
                [composeViewController setMessageBody:[self createDeviceInformationString] isHTML:NO];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
            break;
        }
        case 3: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/habitica"]];
            break;
        }
        case 4: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://habitica.wikia.com/wiki/FAQ"]];
            break;
        }
        case 5: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id994882113"]];
            break;
        }
        case 6: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/HabitRPG/habitrpg-ios/"]];
            break;
        }
        case 7: {
            VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
            viewController.headerText = NSLocalizedString(@"We love open source software.", nil); // optional
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
}


- (NSString*)createDeviceInformationString {
    NSMutableString *informationString = [@"Please describe the bug you encountered:\n\n\n\n\n\n\n\n\n\n\n\n" mutableCopy];
    
    [informationString appendString:NSLocalizedString(@"The following lines help us find and squash the Bug you encountered. Please do not delete/change them.\n", nil)];
    
    [informationString appendString:[NSString stringWithFormat:@"iOS Version: %@\n", [[UIDevice currentDevice] systemVersion]]];
    struct utsname systemInfo;
    uname(&systemInfo);
    [informationString appendString:[NSString stringWithFormat:@"Device: %@\n", [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]]];
    [informationString appendString:[NSString stringWithFormat:NSLocalizedString(@"App Version: %@\n", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    [informationString appendString:[NSString stringWithFormat:@"User UUID: %@\n", [self.sharedManager getUser].id]];
    
    return informationString;
}

@end
