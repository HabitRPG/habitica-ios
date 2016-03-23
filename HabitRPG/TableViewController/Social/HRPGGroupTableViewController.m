//
//  HRPGChatTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGGroupTableViewController.h"
#import <UIImage+YYWebImage.h>
#import <DTAttributedTextView.h>
#import "UIViewController+Markdown.h"
#import "HRPGChatTableViewCell.h"
#import "User.h"
#import "HRPGMessageViewController.h"
#import "HRPGUserProfileViewController.h"
#import "HRPGMessageViewController.h"
#import "HRPGFlagInformationOverlayView.h"
#import <KLCPopup.h>
#import "HRPGPartyMembersViewController.h"
#import "HRPGGroupAboutTableViewController.h"
#import "UIColor+Habitica.h"

@interface HRPGGroupTableViewController ()
@property NSString *replyMessage;
@property UITextView *sizeTextView;
@property NSMutableDictionary *attributes;

@end

@implementation HRPGGroupTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.sizeTextView = [[UITextView alloc] init];
        self.sizeTextView.textContainerInset = UIEdgeInsetsZero;
        self.sizeTextView.contentInset = UIEdgeInsetsZero;
        [self configureMarkdownAttributes];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    UINib *nib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChatMessageCell"];

    [self configureMarkdownAttributes];

    self.user = [self.sharedManager getUser];

    [self fetchGroup];
    [self refresh];
}

- (void)refresh {
    [self.sharedManager fetchGroup:self.groupID
        onSuccess:^() {
            [self.refreshControl endRefreshing];
            [self fetchGroup];
            if (![self.groupID isEqualToString:@"habitrpg"]) {
                self.group.unreadMessages = [NSNumber numberWithBool:NO];
                [self.sharedManager chatSeen:self.group.id];
            }
        }
        onError:^() {
            [self.refreshControl endRefreshing];
            [self.sharedManager displayNetworkError];
        }];
}

- (void)fetchGroup {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.groupID]];

    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results.count == 1) {
        self.group = results[0];

        if (![self.group.isMember boolValue] && [self.group.type isEqualToString:@"guild"] &&
            ![self.groupID isEqualToString:@"habitrpg"]) {
            UIBarButtonItem *barButton =
                [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Join", nil)
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(joinGroup)];
            barButton.tintColor = [UIColor green50];
            self.navigationItem.rightBarButtonItem = barButton;
        }
    } else {
        [self refresh];
    }
}

- (void)setGroup:(Group *)group {
    _group = group;
    self.navigationItem.title = group.name;
}

- (void)joinGroup {
    [self.sharedManager joinGroup:self.group.id
                         withType:self.group.type
                        onSuccess:^() {
                            self.navigationItem.rightBarButtonItem = nil;
                        }
                          onError:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.group) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.group) {
        return 1;
    }
    if (section == 0) {
        if ([self listMembers]) {
            return 2;
        } else {
            return 1;
        }
        return 2;
    } else if (section == [self chatSectionIndex] - 1) {
        return 1;
    } else if (section == [self chatSectionIndex]) {
        return [self.chatMessagesFRC fetchedObjects].count;
    }
    return 0;
}

- (int)chatSectionIndex {
    return 2;
}

- (bool)listMembers {
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.group) {
        return nil;
    }
    if (section == 0) {
        return self.group.name;
    } else if (section == [self chatSectionIndex] - 1) {
        return NSLocalizedString(@"Chat", nil);
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self chatSectionIndex]) {
        ChatMessage *message = [self.chatMessagesFRC
            objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        if (!message.attributedText) {
            message.attributedText = [self renderMarkdown:message.text];
        }
        self.sizeTextView.attributedText = message.attributedText;

        CGSize suggestedSize =
            [self.sizeTextView sizeThatFits:CGSizeMake(self.viewWidth - 26, CGFLOAT_MAX)];

        CGFloat rowHeight = suggestedSize.height + 35;
        return rowHeight;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self chatSectionIndex] - 1) {
        if ([[self.sharedManager getUser].acceptedCommunityGuidelines boolValue]) {
            [self performSegueWithIdentifier:@"MessageSegue" sender:self];
        } else {
            [self performSegueWithIdentifier:@"GuidelinesSegue" sender:self];
        }
    } else if (indexPath.section == 0) {
        if (indexPath.item == 1) {
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
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        cellname = @"MembersCell";
    } else if (indexPath.section == [self chatSectionIndex] - 1) {
        cellname = @"ComposeCell";
    } else if (indexPath.section == [self chatSectionIndex]) {
        cellname = @"ChatMessageCell";
    }
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if (indexPath.section == [self chatSectionIndex]) {
        [self configureChatMessageCell:(HRPGChatTableViewCell *)cell atIndexPath:indexPath];
    } else if ([cellname isEqualToString:@"LoadingCell"]) {
        UIActivityIndicatorView *activityIndicator =
            (UIActivityIndicatorView *)[cell viewWithTag:1];
        [activityIndicator startAnimating];
    } else if ([cellname isEqualToString:@"MembersCell"]) {
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%lu", (unsigned long)[self.group.member count]];
    }
    return cell;
}

- (NSFetchedResultsController *)chatMessagesFRC {
    if (_chatMessagesFRC != nil) {
        return _chatMessagesFRC;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatMessage"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"group.id == %@", self.groupID]];

    NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[ sortDescriptor ];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:self.groupID];
    aFetchedResultsController.delegate = self;
    self.chatMessagesFRC = aFetchedResultsController;

    NSError *error = nil;
    if (![self.chatMessagesFRC performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _chatMessagesFRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:[self chatSectionIndex]];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:[self chatSectionIndex]];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[NSString class]]) {
                [self configureChatMessageCell:(HRPGChatTableViewCell *)cell
                                   atIndexPath:indexPath];
            }
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (IBAction)unwindToGroup:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToListSendMessage:(UIStoryboardSegue *)segue {
    [self.tableView
        deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self chatSectionIndex] - 1]
                      animated:YES];
    HRPGMessageViewController *messageController =
        (HRPGMessageViewController *)[segue sourceViewController];
    [self.sharedManager chatMessage:messageController.messageView.text
                          withGroup:self.groupID
                          onSuccess:^() {
                              [self.sharedManager fetchGroup:self.groupID
                                  onSuccess:^() {
                                      [self fetchGroup];
                                  }
                                  onError:^() {
                                      [self.sharedManager displayNetworkError];
                                  }];
                          }
                            onError:nil];
}

- (IBAction)unwindToAcceptGuidelines:(UIStoryboardSegue *)segue {
    [self.sharedManager updateUser:@{
        @"flags.communityGuidelinesAccepted" : [NSNumber numberWithBool:YES]
    }
        onSuccess:^() {
            [self performSegueWithIdentifier:@"MessageSegue" sender:self];
        }
        onError:^(){

        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MembersSegue"]) {
        HRPGPartyMembersViewController *membersViewController =
            (HRPGPartyMembersViewController *)segue.destinationViewController;
        membersViewController.isLeader = [self.group.leader.id isEqualToString:self.user.id];
        membersViewController.partyID = self.group.id;
    } else if ([segue.identifier isEqualToString:@"AboutSegue"]) {
        HRPGGroupAboutTableViewController *aboutViewController =
            (HRPGGroupAboutTableViewController *)segue.destinationViewController;
        aboutViewController.isLeader = [self.group.leader.id isEqualToString:self.user.id];
        aboutViewController.group = self.group;
    }
}

- (void)configureChatMessageCell:(HRPGChatTableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ChatMessage *message = [self.chatMessagesFRC objectAtIndexPath:indexPath];
    if (!message.attributedText) {
        message.attributedText = [self renderMarkdown:message.text];
    }
    [cell configureForMessage:message withUserID:self.user.id withUsername:self.user.username];
    cell.profileAction = ^() {
        HRPGUserProfileViewController *profileViewController =
            [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        profileViewController.userID = message.uuid;
        profileViewController.username = message.user;
        [self.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.flagAction = ^() {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"HRPGFlagInformationOverlayView"
                                                          owner:self
                                                        options:nil];
        HRPGFlagInformationOverlayView *overlayView = [nibViews objectAtIndex:0];
        overlayView.username = message.user;
        overlayView.message = message.text;
        overlayView.flagAction = ^() {
            [self.sharedManager flagMessage:message
                                  withGroup:self.groupID
                                  onSuccess:nil
                                    onError:nil];
        };
        [overlayView sizeToFit];
        KLCPopup *popup = [KLCPopup popupWithContentView:overlayView
                                                showType:KLCPopupShowTypeBounceIn
                                             dismissType:KLCPopupDismissTypeBounceOut
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:YES];
        [popup show];
    };
    cell.replyAction = ^() {
        NSString *replyMessage = [NSString stringWithFormat:@"@%@ ", message.user];
        UINavigationController *messageNavigationController =
            [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
        HRPGMessageViewController *messageViewController =
            (HRPGMessageViewController *)messageNavigationController.topViewController;
        messageViewController.presetText = replyMessage;
        [self.navigationController presentViewController:messageNavigationController
                                                animated:YES
                                              completion:nil];
    };

    cell.plusOneAction = ^() {
        [self.sharedManager likeMessage:message withGroup:self.groupID onSuccess:nil onError:nil];
    };

    cell.deleteAction = ^() {
        [self.sharedManager deleteMessage:message withGroup:self.groupID onSuccess:nil onError:nil];
    };
}

@end
