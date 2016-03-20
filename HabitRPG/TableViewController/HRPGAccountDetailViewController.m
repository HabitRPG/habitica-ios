//
//  HRPGAccountDetailViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 18/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAccountDetailViewController.h"
#import "User.h"
#import <PDKeychainBindings.h>
#import "HRPGCopyTableViewCell.h"

@interface HRPGAccountDetailViewController ()

@property User *user;

@end

@implementation HRPGAccountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Authentication", @"Noun");
    } else {
        return NSLocalizedString(@"API", nil);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"Copy these for use in third party applications. However, think "
                                 @"of your API Token like a password, and do not share it "
                                 @"publicly. You may occasionally be asked for your User ID, but "
                                 @"never post your API Token where others can see it, including "
                                 @"on Github.",
                                 nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            cell.textLabel.text = NSLocalizedString(@"Login name", nil);
            cell.detailTextLabel.text = self.user.username;
        } else if (indexPath.item == 1) {
            cell.textLabel.text = NSLocalizedString(@"email", nil);
            cell.detailTextLabel.text = self.user.email;
        } else if (indexPath.item == 2) {
            cell.textLabel.text = NSLocalizedString(@"Login Method", nil);
            if (self.user.email) {
                cell.detailTextLabel.text = NSLocalizedString(@"Local", nil);
            } else {
                cell.detailTextLabel.text = @"Facebook";
            }
        }
    } else if (indexPath.section == 1) {
        PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
        if (indexPath.item == 0) {
            cell.textLabel.text = NSLocalizedString(@"User ID", nil);
            cell.detailTextLabel.text = self.user.id;
        } else if (indexPath.item == 1) {
            cell.textLabel.text = NSLocalizedString(@"API Key", nil);
            cell.detailTextLabel.text = [keyChain stringForKey:@"key"];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HRPGCopyTableViewCell *cell =
        (HRPGCopyTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell selectedCell];
}

@end
