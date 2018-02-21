//
//  HRPGChatTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <KLCPopup/KLCPopup.h>
#import "HRPGGroupTableViewController.h"
#import "HRPGFlagInformationOverlayView.h"
#import "HRPGGroupAboutTableViewController.h"
#import "HRPGMessageViewController.h"
#import "HRPGPartyMembersViewController.h"
#import "HRPGUserProfileViewController.h"
#import "UIColor+Habitica.h"
#import "UIViewController+Markdown.h"
#import "NSString+Emoji.h"
#import "Habitica-Swift.h"

@interface HRPGGroupTableViewController ()
@end

@implementation HRPGGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor purple400];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.user = [[HRPGManager sharedManager] getUser];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor gray700];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchGroup:self.groupID
        onSuccess:^() {
            if (self) {
                [self.refreshControl endRefreshing];
            }
        }
        onError:^() {
            if (self) {
                [self.refreshControl endRefreshing];
                [[HRPGManager sharedManager] displayNetworkError];
            }
        }];
}

- (void)setGroup:(Group *)group {
    _group = group;
    self.navigationItem.title = [group.name stringByReplacingEmojiCheatCodesWithUnicode];

    [self.tableView reloadData];
    
    if (![self.group.isMember boolValue] && [self.group.type isEqualToString:@"guild"] &&
        ![self.groupID isEqualToString:@"00000000-0000-4000-A000-000000000000"]) {
        UIBarButtonItem *barButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Join", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(joinGroup)];
        barButton.tintColor = [UIColor green50];
        self.navigationItem.rightBarButtonItem = barButton;
    }
}

- (void)joinGroup {
    [[HRPGManager sharedManager] joinGroup:self.group.id
                         withType:self.group.type
                        onSuccess:^() {
                            self.navigationItem.rightBarButtonItem = nil;
                        } onError:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.group) {
        return 1;
    }
    if (section == 0) {
        if ([self listMembers]) {
            return 3;
        } else {
            return 2;
        }
    }
    return 0;
}

- (bool)listMembers {
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.group) {
        return nil;
    }
    if (section == 0) {
        return [self.group.name stringByReplacingEmojiCheatCodesWithUnicode];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.item == 1 && self.listMembers) {
            [self performSegueWithIdentifier:@"MembersSegue" sender:self];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname;
    if (!self.group) {
        cellname = @"LoadingCell";
    } else if (indexPath.section == 0 && indexPath.item == 0) {
        cellname = @"AboutCell";
    } else if (indexPath.section == 0 && indexPath.item == 1 && self.listMembers) {
        cellname = @"MembersCell";
    } else if (indexPath.section == 0) {
        cellname = @"ChallengeCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if ([cellname isEqualToString:@"LoadingCell"]) {
        UIActivityIndicatorView *activityIndicator = [cell viewWithTag:1];
        [activityIndicator startAnimating];
    } else if ([cellname isEqualToString:@"MembersCell"]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.group.memberCount];
    }
    return cell;
}

- (IBAction)unwindToGroup:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToAcceptGuidelines:(UIStoryboardSegue *)segue {
    __weak HRPGGroupTableViewController *weakSelf = self;
    [[HRPGManager sharedManager] updateUser:@{
        @"flags.communityGuidelinesAccepted" : @YES
    }
        onSuccess:^() {
            [weakSelf performSegueWithIdentifier:@"MessageSegue" sender:self];
        }
        onError:^(){

        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MembersSegue"]) {
        HRPGPartyMembersViewController *membersViewController = segue.destinationViewController;
        membersViewController.isLeader = [self.group.leader.id isEqualToString:self.user.id];
        membersViewController.partyID = self.group.id;
    } else if ([segue.identifier isEqualToString:@"AboutSegue"]) {
        HRPGGroupAboutTableViewController *aboutViewController = segue.destinationViewController;
        aboutViewController.isLeader = [self.group.leader.id isEqualToString:self.user.id];
        aboutViewController.group = self.group;
    } else if ([segue.identifier isEqualToString:@"ChallengeSegue"]) {
        ChallengeTableViewController *viewController = segue.destinationViewController;
        viewController.shownGuilds = @[self.groupID];
        viewController.showOnlyUserChallenges = NO;
    }
}

@end
