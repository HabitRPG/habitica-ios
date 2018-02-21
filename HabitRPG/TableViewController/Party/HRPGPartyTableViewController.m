//
//  HRPGPartyTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGPartyTableViewController.h"
#import "HRPGGroupFormViewController.h"
#import "HRPGItemViewController.h"
#import "HRPGQRCodeView.h"
#import "HRPGSharingManager.h"
#import "UIView+Screenshot.h"

@interface HRPGPartyTableViewController ()
@property NSUserDefaults *defaults;
@end

@implementation HRPGPartyTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.tutorialIdentifier = @"party";
        self.defaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (bool)listMembers {
    return YES;
}

- (NSString *)groupID {
    return self.user.partyID;
}

- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier {
    UITableViewCell *cell =
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    return [self.tableView convertRect:cell.frame
                                toView:self.parentViewController.parentViewController.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.group) {
        return [super numberOfSectionsInTableView:tableView];
    } else {
        if (self.user.invitedParty) {
            return 1;
        } else {
            return 3;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.group) {
        return [super tableView:tableView numberOfRowsInSection:section];
    } else {
        switch (section) {
            case 0:
                if (self.user.invitedParty) {
                    return 3;
                } else {
                    return 1;
                }
            case 1:
                return 1;
            case 2: {
                return 2;
            }
            default:
                return 0;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.group) {
        if (self.user.invitedParty) {
            return 44;
        } else {
            if (indexPath.section == 2 && indexPath.item == 0) {
                return 100;
            } else if (indexPath.section == 1 && indexPath.item == 0) {
                return 60;
            } else if (indexPath.section == 0 && indexPath.item == 0) {
                return 100;
            } else if (indexPath.section == 2 && indexPath.item == 1) {
                return self.view.frame.size.width < 320 ? self.view.frame.size.width : 320;
            }
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.user.invitedParty && !self.group) {
        if (indexPath.item == 1) {
            [[HRPGManager sharedManager] joinGroup:self.user.invitedParty
                withType:@"party"
                onSuccess:^() {
                    [self.tableView reloadData];
                }
                onError:nil];
        } else if (indexPath.item == 2) {
            // TODO
        }
        return;
    }

    if (!self.group) {
        return;
    }
    
    if (!self.quest) {
        if (indexPath.section == 1 && indexPath.item == 0) {
            [self openQuestSelection];
        }
    }
    
    return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.group) {
        NSString *cellname;
        if (self.user.invitedParty) {
            if (indexPath.item == 0) {
                cellname = @"BaseCell";
            } else {
                cellname = @"CenteredCell";
            }
        } else {
            if (indexPath.section == 2 && indexPath.item == 0) {
                cellname = @"JoinPartyCell";
            } else if (indexPath.section == 2 && indexPath.item == 1) {
                cellname = @"QRCodeCell";
            } else if (indexPath.section == 1 && indexPath.item == 0) {
                cellname = @"CreatePartyCell";
            } else if (indexPath.section == 0 && indexPath.item == 0) {
                cellname = @"PartyDescriptionCell";
            }
        }
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
        if (self.user.invitedParty) {
            if (indexPath.item == 0) {
                cell.textLabel.text =
                    [NSString stringWithFormat:NSLocalizedString(@"Invited to %@", nil),
                                               self.user.invitedPartyName];
            } else if (indexPath.item == 1) {
                cell.textLabel.text = NSLocalizedString(@"Accept", nil);
            } else if (indexPath.item == 2) {
                cell.textLabel.text = NSLocalizedString(@"Reject", nil);
            }
        } else {
            if (indexPath.section == 2 && indexPath.item == 0) {
                UILabel *userIDLabel = [cell viewWithTag:1];
                userIDLabel.text = self.user.id;
            } else if (indexPath.section == 2 && indexPath.item == 1) {
                HRPGQRCodeView *qrCodeView = [cell viewWithTag:1];
                qrCodeView.userID = self.user.id;
                [qrCodeView setAvatarViewWithUser:self.user];
                __weak HRPGPartyTableViewController *weakSelf = self;
                __weak HRPGQRCodeView *weakQRCodeView = qrCodeView;
                qrCodeView.shareAction = ^() {
                    [HRPGSharingManager shareItems:@[[weakQRCodeView pb_takeScreenshot]] withPresentingViewController:weakSelf withSourceView:weakQRCodeView];
                };
            }
        }
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GroupFormSegue"]) {
        if (!self.group) {
            UINavigationController *navigationController = segue.destinationViewController;
            HRPGGroupFormViewController *partyFormViewController =
                (HRPGGroupFormViewController *)navigationController.topViewController;
            partyFormViewController.editGroup = NO;
            partyFormViewController.groupType = @"party";
            return;
        }
    }
    [super prepareForSegue:segue sender:sender];
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"party"]) {
        return @{
            @"text" :
                NSLocalizedString(@"This is where you and your friends can hold each other "
                                  @"accountable to your goals and fight monsters with your tasks!",
                                  nil)
        };
    } else if ([tutorialIdentifier isEqualToString:@"inviteParty"]) {
        return
            @{ @"text" : NSLocalizedString(@"Tap to invite friends and view party members.", nil) };
    }
    return nil;
}

- (bool)canInviteToQuest {
    return YES;
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGGroupFormViewController *formViewController = segue.sourceViewController;
    if (formViewController.editGroup) {
        [[HRPGManager sharedManager] updateGroup:formViewController.group onSuccess:nil onError:nil];
    } else {
        [[HRPGManager sharedManager] createGroup:formViewController.group
                              onSuccess:^() {
                                  [self.tableView reloadData];
                              }
                                onError:nil];
    }
}

- (void) openQuestSelection {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *itemNavigationController =
    [storyBoard instantiateViewControllerWithIdentifier:@"ItemNavigationController"];
    HRPGItemViewController *itemViewController = (HRPGItemViewController *)itemNavigationController.topViewController;
    itemViewController.itemType = @"quests";
    itemViewController.shouldDismissAfterAction = YES;
    [self.navigationController presentViewController:itemNavigationController animated:YES completion:nil];
}

@end
