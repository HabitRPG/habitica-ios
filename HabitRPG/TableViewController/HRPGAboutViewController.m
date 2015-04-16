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

@interface HRPGAboutViewController ()
@property BOOL shouldReshowTopHeader;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*)self.navigationController;
        if (navigationController.isTopHeaderVisible) {
            [navigationController hideTopBar];
            self.shouldReshowTopHeader = YES;
        } else {
            self.shouldReshowTopHeader = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*)self.navigationController;
        if (self.shouldReshowTopHeader) {
            [navigationController showTopBar];
        }
    }
    
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = @"BasicCell";
    if (indexPath.item == 0) {
        cellName = @"RightDetailCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    
    if (indexPath.item == 0) {
        cell.textLabel.text = NSLocalizedString(@"Website", nil);
        cell.detailTextLabel.text = @"habitrpg.com";
    } else if (indexPath.item == 1) {
        cell.textLabel.text = NSLocalizedString(@"Send feedback", nil);
    } else if (indexPath.item == 2) {
        cell.textLabel.text = NSLocalizedString(@"Report a bug", nil);
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    switch (indexPath.item) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://habitrpg.com/"]];
            break;
        case 1:
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[@"mobile@habitrpg.com"]];
                [composeViewController setSubject:@"[iOS] Feedback"];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
        case 2:
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[@"mobile@habitrpg.com"]];
                [composeViewController setSubject:@"[iOS] Bugreport"];
                [composeViewController setMessageBody:[self createDeviceInformationString] isHTML:NO];
                [self presentViewController:composeViewController animated:YES completion:nil];
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
    [informationString appendString:[NSString stringWithFormat:@"Device: %@ %@\n", [[UIDevice currentDevice] model], [[UIDevice currentDevice] name]]];
    [informationString appendString:[NSString stringWithFormat:NSLocalizedString(@"App Version: %@\n", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    [informationString appendString:[NSString stringWithFormat:@"User UUID: %@\n", [self.sharedManager getUser].id]];
    
    return informationString;
}

@end
