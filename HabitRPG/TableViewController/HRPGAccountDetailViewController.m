//
//  HRPGAccountDetailViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 18/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAccountDetailViewController.h"
#import <PDKeychainBindings.h>
#import "HRPGCopyTableViewCell.h"
#import "HRPGQRCodeView.h"
#import "UIView+Screenshot.h"
#import "HRPGSharingManager.h"

@interface HRPGAccountDetailViewController ()

@property User *user;

@end

@implementation HRPGAccountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"Authentication", @"Noun");
    } else if (section == 2) {
        return NSLocalizedString(@"API", nil);
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return NSLocalizedString(@"Copy these for use in third party applications. However, think "
                                 @"of your API Token like a password, and do not share it "
                                 @"publicly. You may occasionally be asked for your User ID, but "
                                 @"never post your API Token where others can see it, including "
                                 @"on Github.",
                                 nil);
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.view.frame.size.width < 320 ? self.view.frame.size.width : 320;
    } else {
        return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"QRCodeCell" forIndexPath:indexPath];
        HRPGQRCodeView *qrCodeView = [cell viewWithTag:1];
        qrCodeView.userID = self.user.id;
        [qrCodeView setAvatarViewWithUser:self.user];
        __weak HRPGAccountDetailViewController *weakSelf = self;
        __weak HRPGQRCodeView *weakQRCodeView = qrCodeView;
        qrCodeView.shareAction = ^() {
            [HRPGSharingManager shareItems:@[[weakQRCodeView pb_takeScreenshot]] withPresentingViewController:weakSelf withSourceView:weakQRCodeView];
        };
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (indexPath.item == 0) {
            cell.textLabel.text = NSLocalizedString(@"Login name", nil);
            cell.detailTextLabel.text = self.user.username;
        } else if (indexPath.item == 1) {
            cell.textLabel.text = NSLocalizedString(@"Email", nil);
            cell.detailTextLabel.text = self.user.email;
        } else if (indexPath.item == 2) {
            cell.textLabel.text = NSLocalizedString(@"Login Methods", nil);
            NSMutableArray *loginMethods = [NSMutableArray arrayWithCapacity:3];
            if (self.user.email) {
                [loginMethods addObject:NSLocalizedString(@"Local", nil)];
            }
            if (self.user.facebookID) {
                [loginMethods addObject:@"Facebook"];
            }
            if (self.user.googleID) {
                [loginMethods addObject:@"Google"];
            }
            cell.detailTextLabel.text = [loginMethods componentsJoinedByString:@", "];
        }
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
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
    if (indexPath.section > 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        HRPGCopyTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell selectedCell];
    }
}

@end
