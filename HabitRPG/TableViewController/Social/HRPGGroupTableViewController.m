//
//  HRPGChatTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
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
    __weak HRPGGroupTableViewController *weakSelf = self;
    [self.sharedManager fetchGroup:self.groupID
        onSuccess:^() {
            if (weakSelf) {
                [weakSelf.refreshControl endRefreshing];
                [weakSelf fetchGroup];
                if (![weakSelf.groupID isEqualToString:@"00000000-0000-4000-A000-000000000000"]) {
                    weakSelf.group.unreadMessages = @NO;
                    [weakSelf.sharedManager chatSeen:weakSelf.group.id];
                }
            }
        }
        onError:^() {
            if (weakSelf) {
                [weakSelf.refreshControl endRefreshing];
                [weakSelf.sharedManager displayNetworkError];
            }
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
            ![self.groupID isEqualToString:@"00000000-0000-4000-A000-000000000000"]) {
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
    self.navigationItem.title = [group.name stringByReplacingEmojiCheatCodesWithUnicode];

    if (self.tableView.numberOfSections != [self numberOfSectionsInTableView:self.tableView]) {
        [self.tableView reloadData];
    }
}

- (void)joinGroup {
    __weak HRPGGroupTableViewController *weakSelf = self;
    [self.sharedManager joinGroup:self.group.id
                         withType:self.group.type
                        onSuccess:^() {
                            weakSelf.navigationItem.rightBarButtonItem = nil;
                        } onError:nil];
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
        return [self.group.name stringByReplacingEmojiCheatCodesWithUnicode];
    } else if (section == [self chatSectionIndex] - 1) {
        return NSLocalizedString(@"Chat", nil);
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self chatSectionIndex]) {
        ChatMessage *message = [self chatMessageAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
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
        if ([[self.sharedManager getUser].flags.communityGuidelinesAccepted boolValue]) {
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
        UIActivityIndicatorView *activityIndicator = [cell viewWithTag:1];
        [activityIndicator startAnimating];
    } else if ([cellname isEqualToString:@"MembersCell"]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.group.memberCount];
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
                [self configureChatMessageCell:(HRPGChatTableViewCell *)cell atIndexPath:indexPath];
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
    HRPGMessageViewController *messageController = [segue sourceViewController];
    __weak HRPGGroupTableViewController *weakSelf = self;
    [self.sharedManager chatMessage:messageController.messageView.text
                          withGroup:self.groupID
                          onSuccess:^() {
                              [weakSelf.sharedManager fetchGroup:weakSelf.groupID
                                  onSuccess:^() {
                                      [weakSelf fetchGroup];
                                  }
                                  onError:^() {
                                      [weakSelf.sharedManager displayNetworkError];
                                  }];
                          }
                            onError:nil];
}

- (IBAction)unwindToAcceptGuidelines:(UIStoryboardSegue *)segue {
    __weak HRPGGroupTableViewController *weakSelf = self;
    [self.sharedManager updateUser:@{
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
    }
}

- (void)configureChatMessageCell:(HRPGChatTableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ChatMessage *message = [self chatMessageAtIndexPath:objectIndexPath];
    if (!message.attributedText) {
        message.attributedText = [self renderMarkdown:message.text];
    }
    [cell configureForMessage:message withUserID:self.user.id withUsername:self.user.username isModerator:([self.user.contributorLevel intValue] >= 8)];
    __weak HRPGGroupTableViewController *weakSelf = self;
    cell.profileAction = ^() {
        HRPGUserProfileViewController *profileViewController =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        profileViewController.userID = message.uuid;
        profileViewController.username = message.user;
        [weakSelf.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.flagAction = ^() {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"HRPGFlagInformationOverlayView"
                                                          owner:weakSelf
                                                        options:nil];
        HRPGFlagInformationOverlayView *overlayView = nibViews[0];
        overlayView.username = message.user;
        overlayView.message = message.text;
        overlayView.flagAction = ^() {
            [weakSelf.sharedManager flagMessage:message
                                  withGroup:weakSelf.groupID
                                  onSuccess:nil
                                    onError:nil];
        };
        [overlayView sizeToFit];
        KLCPopup *popup = [KLCPopup popupWithContentView:overlayView
                                                showType:KLCPopupShowTypeBounceIn
                                             dismissType:KLCPopupDismissTypeBounceOut
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:NO];
        [popup show];
    };
    cell.replyAction = ^() {
        NSString *replyMessage = [NSString stringWithFormat:@"@%@ ", message.user];
        UINavigationController *messageNavigationController =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
        HRPGMessageViewController *messageViewController =
            (HRPGMessageViewController *)messageNavigationController.topViewController;
        messageViewController.presetText = replyMessage;
        [weakSelf.navigationController presentViewController:messageNavigationController
                                                animated:YES
                                              completion:nil];
    };

    cell.plusOneAction = ^() {
        [weakSelf.sharedManager likeMessage:message withGroup:weakSelf.groupID onSuccess:^() {
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } onError:nil];
    };

    cell.deleteAction = ^() {
        [weakSelf.sharedManager deleteMessage:message withGroup:weakSelf.groupID onSuccess:nil onError:nil];
    };
}

- (id)chatMessageAtIndexPath:(NSIndexPath *)indexPath {
    id item  = nil;
    if ([[self.chatMessagesFRC sections] count] > [indexPath section]){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.chatMessagesFRC sections] objectAtIndex:[indexPath section]];
        if ([sectionInfo numberOfObjects] > [indexPath row]){
            item = [self.chatMessagesFRC objectAtIndexPath:indexPath];
        }
    }
    return item;
}

@end
