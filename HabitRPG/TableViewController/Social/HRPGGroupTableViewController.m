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
@property NSString *replyMessage;
@property UITextView *sizeTextView;
@property NSIndexPath *expandedChatPath;
@end

@implementation HRPGGroupTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.sizeTextView = [[UITextView alloc] init];
        self.sizeTextView.textContainerInset = UIEdgeInsetsZero;
        self.sizeTextView.contentInset = UIEdgeInsetsZero;
        self.sizeTextView.font = [CustomFontMetrics scaledSystemFontOfSize:15.0f compatibleWith:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor purple400];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    UINib *nib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChatMessageCell"];
    UINib *systemNib = [UINib nibWithNibName:@"SystemMessageTableViewCell" bundle:nil];
    [[self tableView] registerNib:systemNib forCellReuseIdentifier:@"SystemMessageCell"];

    self.user = [[HRPGManager sharedManager] getUser];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor gray700];

    [self fetchGroup];
    [self refresh];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self renderAttributedTexts];
}

- (void)renderAttributedTexts {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (ChatMessage *message in self.chatMessagesFRC.fetchedObjects) {
            if (!message.attributedText) {
                message.attributedText = [self renderMarkdown:message.text];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
        });
    });
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchGroup:self.groupID
        onSuccess:^() {
            if (self) {
                [self.refreshControl endRefreshing];
                [self fetchGroup];
                if (![self.groupID isEqualToString:@"00000000-0000-4000-A000-000000000000"]) {
                    self.group.unreadMessages = @NO;
                    [[HRPGManager sharedManager] chatSeen:self.group.id];
                }
            }
        }
        onError:^() {
            if (self) {
                [self.refreshControl endRefreshing];
                [[HRPGManager sharedManager] displayNetworkError];
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
        BOOL shouldReload = NO;
        if (self.group == nil) {
            shouldReload = YES;
        }
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
        if (shouldReload) {
            [self.tableView reloadData];
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
    [[HRPGManager sharedManager] joinGroup:self.group.id
                         withType:self.group.type
                        onSuccess:^() {
                            self.navigationItem.rightBarButtonItem = nil;
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.chatSectionIndex != indexPath.section) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ChatMessage *message = [self chatMessageAtIndexPath:objectIndexPath];
    self.sizeTextView.text = message.text;
    
    CGFloat spacing = 41;
    if ([message.user isEqualToString:self.user.username]) {
        spacing = 97;
    }
    CGSize suggestedSize = [self.sizeTextView sizeThatFits:CGSizeMake(self.viewWidth - spacing, CGFLOAT_MAX)];
    
    CGFloat rowHeight = suggestedSize.height + 72;
    if (self.expandedChatPath.item == indexPath.item) {
        rowHeight += 36;
    }
    return rowHeight;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self chatSectionIndex] - 1) {
        if ([[[HRPGManager sharedManager] getUser].flags.communityGuidelinesAccepted boolValue]) {
            [self performSegueWithIdentifier:@"MessageSegue" sender:self];
        } else {
            [self performSegueWithIdentifier:@"GuidelinesSegue" sender:self];
        }
    } else if (indexPath.section == 0) {
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
    } else if (indexPath.section == [self chatSectionIndex] - 1) {
        cellname = @"ComposeCell";
    } else if (indexPath.section == [self chatSectionIndex]) {
        NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        ChatMessage *message = [self chatMessageAtIndexPath:objectIndexPath];
        if (message.user) {
            cellname = @"ChatMessageCell";
        } else if (message) {
            cellname = @"SystemMessageCell";
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if ([cellname isEqualToString:@"ChatMessageCell"]) {
        [self configureChatMessageCell:(ChatTableViewCell *)cell atIndexPath:indexPath];
    } else if ([cellname isEqualToString:@"SystemMessageCell"]) {
        NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        [(SystemMessageTableViewCell *)cell configureWithChatMessage:[self chatMessageAtIndexPath:objectIndexPath]];
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
        case NSFetchedResultsChangeInsert: {
            NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            ChatMessage *message = [self chatMessageAtIndexPath:objectIndexPath];
            message.attributedText = [self renderMarkdown:message.text];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[NSString class]]) {
                [self configureChatMessageCell:(ChatTableViewCell *)cell atIndexPath:indexPath];
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
    [[HRPGManager sharedManager] chatMessage:messageController.messageView.text
                          withGroup:self.groupID
                          onSuccess:^() {
                              [[HRPGManager sharedManager] fetchGroup:self.groupID
                                  onSuccess:^() {
                                      [self fetchGroup];
                                  }
                                  onError:^() {
                                      [[HRPGManager sharedManager] displayNetworkError];
                                  }];
                          }
                            onError:nil];
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

- (void)configureChatMessageCell:(ChatTableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ChatMessage *message = [self chatMessageAtIndexPath:objectIndexPath];
    
    [cell configureWithChatMessage:message userID:self.user.id username:self.user.username isModerator:[self.user isModerator] isExpanded:[self.expandedChatPath isEqual:indexPath]];
    
    cell.profileAction = ^() {
        HRPGUserProfileViewController *profileViewController =
            [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        profileViewController.userID = message.uuid;
        profileViewController.username = message.user;
        [self.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.reportAction = ^() {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"HRPGFlagInformationOverlayView"
                                                          owner:self
                                                        options:nil];
        HRPGFlagInformationOverlayView *overlayView = nibViews[0];
        overlayView.username = message.user;
        overlayView.message = message.text;
        overlayView.flagAction = ^() {
            [[HRPGManager sharedManager] flagMessage:message
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
                                   dismissOnContentTouch:NO];
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
        [[HRPGManager sharedManager] likeMessage:message withGroup:self.groupID onSuccess:^() {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } onError:nil];
    };
    cell.deleteAction = ^() {
        [[HRPGManager sharedManager] deleteMessage:message withGroup:self.groupID onSuccess:nil onError:nil];
    };
    cell.copyAction = ^{
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:message.text];
    };
    cell.expandAction = ^{
        [self expandSelectedCell:indexPath];
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

- (void)expandSelectedCell:(NSIndexPath *)indexPath {
    NSIndexPath *expandedPath = self.expandedChatPath;
    if ([self.tableView numberOfRowsInSection:[self chatSectionIndex]] < expandedPath.item) {
        expandedPath = nil;
    }
    self.expandedChatPath = indexPath;
    if (expandedPath == nil || indexPath.item == expandedPath.item) {
        ChatTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.isExpanded = !cell.isExpanded;
        if (!cell.isExpanded) {
            self.expandedChatPath = nil;
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    } else {
        ChatTableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:expandedPath];
        ChatTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView beginUpdates];
        cell.isExpanded = YES;
        oldCell.isExpanded = NO;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath, expandedPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

@end
