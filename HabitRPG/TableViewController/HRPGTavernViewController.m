//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGTavernViewController.h"
#import "HRPGAppDelegate.h"
#import "ChatMessage.h"
#import <CRToast.h>
#import <NSDate+TimeAgo.h>
#import "HRPGMessageViewController.h"
#import "Group.h"
#import "Quest.h"
#import "HRPGProgressView.h"
#import "HRPGQuestDetailViewController.h"
#import "NSNumber+abbreviation.h"
#import "NSString+Emoji.h"
#import "HRPGUserProfileViewController.h"
#import "NSMutableAttributedString_GHFMarkdown.h"
#import <CoreText/CoreText.h>

@interface HRPGTavernViewController ()
@property Group *tavern;
@property Quest *quest;
@property NSIndexPath *selectedIndex;
@property NSIndexPath *buttonIndex;
@property NSString *replyMessage;
@property NSMutableArray *rowHeights;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation HRPGTavernViewController
User *user;
ChatMessage *selectedMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.rowHeights = [NSMutableArray array];
    
    user = [self.sharedManager getUser];
    
    [self fetchTavern];
}

- (void)refresh {
    [self.sharedManager fetchGroup:@"habitrpg" onSuccess:^() {
        [self.refreshControl endRefreshing];
        [self fetchTavern];
    }                      onError:^() {
        [self.refreshControl endRefreshing];
        [self.sharedManager displayNetworkError];
    }];
}

- (void) fetchTavern {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == 'habitrpg'"]];
    
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results.count == 1) {
        self.tavern = results[0];
        if (self.tavern.questKey) {
            [self fetchQuest];
        } else {
            if ([self.tableView numberOfSections] == 3) {
                [self.tableView beginUpdates];
                self.quest = nil;
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
    } else {
        [self refresh];
    }
}

- (void)fetchQuest {
    if (self.tavern.questKey) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quest" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", self.tavern.questKey]];
        NSError *error;
        self.quest = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error][0];
        [self.tableView reloadData];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.tavern.questActive boolValue]) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1 && [self.tavern.questActive boolValue]) {
        return 3;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        if (self.buttonIndex) {
            return [sectionInfo numberOfObjects]+1;
        } else {
            return [sectionInfo numberOfObjects];
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1 && [self.tavern.questActive boolValue]) {
        return NSLocalizedString(@"World Quest", nil);
    } else {
        return NSLocalizedString(@"Chat", nil);
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 123;
    } else if (indexPath.section == 1 && [self.tavern.questActive boolValue]) {
        if (indexPath.item == 0) {
            NSInteger height = [self.quest.text boundingRectWithSize:CGSizeMake(270.0f, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                                                  }
                                                        context:nil].size.height + 22;
            return height;
        } else {
            NSInteger height = [@"50/100" boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{
                                                                 NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                                 }
                                                       context:nil].size.height + 20;
            return height;
        }
    } else {
        if (self.buttonIndex && self.buttonIndex.item == indexPath.item) {
            return 44;
        }
        
        ChatMessage *message;
        if (self.buttonIndex && self.buttonIndex.item < indexPath.item) {
            if (self.rowHeights.count > indexPath.item-1) {
                if (self.rowHeights[indexPath.item-1] != [NSNull null]) {
                    return [self.rowHeights[indexPath.item-1] doubleValue];
                }
            } else {
                [self.rowHeights addObject:[NSNull null]];
            }
            message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item-1 inSection:0]];
        } else {
            if (self.rowHeights.count > indexPath.item) {
                if (self.rowHeights[indexPath.item] != [NSNull null]) {
                    return [self.rowHeights[indexPath.item] doubleValue];
                }
            } else {
                [self.rowHeights addObject:[NSNull null]];
            }
            message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        }
        double rowHeight = [message.text boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
                                          context:nil].size.height + 61;
        if (self.buttonIndex && self.buttonIndex.item < indexPath.item) {
            self.rowHeights[indexPath.item-1] = [NSNumber numberWithDouble:rowHeight];
        } else {
            self.rowHeights[indexPath.item] = [NSNumber numberWithDouble:rowHeight];
        }
        return rowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *notificationColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
    self.selectedIndex = indexPath;
    if (indexPath.section == 0 && indexPath.item == 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[cell viewWithTag:2];
        [indicator startAnimating];
        [UIView animateWithDuration:0.4 animations:^() {
            label.hidden = YES;
            indicator.hidden = NO;
        } completion:^(BOOL completed) {
            if (completed) {
            }
        }];
        [self.sharedManager sleepInn:^() {
            NSString *notificationText;
            if (user.sleep) {
                notificationText = NSLocalizedString(@"Sleep tight!", nil);
            } else {
                notificationText = NSLocalizedString(@"Wakey Wakey!", nil);
            }
            NSDictionary *options = @{kCRToastTextKey : notificationText,
                    kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                    kCRToastBackgroundColorKey : notificationColor,
            };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
            }];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        onError:^() {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 1 && self.tavern.questActive) {
        if (indexPath.item == 0) {
            [self performSegueWithIdentifier:@"QuestDetailSegue" sender:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else {
        if (self.buttonIndex && self.buttonIndex.item < indexPath.item) {
            selectedMessage = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item-1 inSection:0]];
        } else {
            selectedMessage = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        }
        [self.tableView beginUpdates];
        if (self.buttonIndex) {
            [self.tableView deleteRowsAtIndexPaths:@[self.buttonIndex] withRowAnimation:UITableViewRowAnimationTop];
        }
        NSIndexPath *newIndex = [NSIndexPath indexPathForItem:indexPath.item+1 inSection:indexPath.section];
        if (newIndex.item != self.buttonIndex.item) {
            if (self.buttonIndex && self.buttonIndex.item < newIndex.item) {
                self.buttonIndex = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
            } else {
                self.buttonIndex = newIndex;
            }
            [self.tableView insertRowsAtIndexPaths:@[self.buttonIndex] withRowAnimation:UITableViewRowAnimationTop];
        } else {
            self.buttonIndex = nil;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [self.tableView endUpdates];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname;
    if (indexPath.section == 0 && indexPath.item == 0) {
        cellname = @"InnCell";
    } else if (indexPath.section == 1 && [self.tavern.questActive boolValue]) {
        if (indexPath.item == 0) {
            cellname = @"QuestCell";
        } else if (indexPath.item == 1) {
            cellname = @"LifeCell";
        } else if (indexPath.item == 2) {
            cellname = @"RageCell";
        }
    } else {
        if (self.buttonIndex && indexPath.item == self.buttonIndex.item) {
            ChatMessage *message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item-1 inSection:0]];
            if ([message.user isEqualToString: user.username]) {
                cellname = @"OwnButtonCell";
            } else {
                cellname = @"ButtonCell";
            }
        } else {
            cellname = @"ChatCell";
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.item == 0) {
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        if (user.sleep) {
            label.text = NSLocalizedString(@"Leave the Inn", nil);
            label.textColor = [UIColor colorWithRed:0.894 green:0.008 blue:0.000 alpha:1.000];
        } else {
            label.text = NSLocalizedString(@"Rest in the Inn", nil);
            label.textColor = [UIColor colorWithRed:0.366 green:0.599 blue:0.014 alpha:1.000];
        }
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[cell viewWithTag:2];
        label.hidden = NO;
        indicator.hidden = YES;
        
        UIImageView *innImageView = (UIImageView*)[cell viewWithTag:3];
        NSString *url = @"http://pherth.net/habitrpg/npc_daniel.png";
        if ([self.tavern.worldDmgTavern boolValue]) {
            url = @"http://pherth.net/habitrpg/npc_daniel_broken.png";
        }
        [innImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithContentsOfFile:@"Placeholder"]];
    } else {
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"group.id == 'habitrpg'"]];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];


    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"tavern"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    int section = 1;
    if ([self.tavern.questActive boolValue]) {
        section = 2;
    }
    switch (type) {
        case NSFetchedResultsChangeInsert:
            newIndexPath = [NSIndexPath indexPathForItem:newIndexPath.item inSection:section];
            if (self.rowHeights.count > newIndexPath.item) {
                [self.rowHeights insertObject:[NSNull null] atIndex:newIndexPath.item];
            } else {
                [self.rowHeights addObject:[NSNull null]];
            }
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:section];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:section];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:section];
            newIndexPath = [NSIndexPath indexPathForItem:newIndexPath.item inSection:section];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    int section = 1;
    if ([self.tavern.questActive boolValue]) {
        section = 2;
    }
    NSInteger messageCount = [self.tableView numberOfRowsInSection:section];
    if (self.rowHeights.count > messageCount) {
        [self.rowHeights removeObjectsInRange:NSMakeRange(messageCount, self.rowHeights.count - messageCount)];
    }
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && [self.tavern.questActive boolValue]) {
        if (indexPath.item == 0) {
            if (self.tavern.questKey != nil) {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.textLabel.text = self.quest.text;
                cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            }
        } else if (indexPath.item == 1) {
            UILabel *lifeLabel = (UILabel *) [cell viewWithTag:1];
            lifeLabel.text = [NSString stringWithFormat:@"Health: %@ / %@", [self.tavern.questHP abbreviateNumber], [self.quest.bossHp abbreviateNumber]];
            lifeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            HRPGProgressView *lifeBar = (HRPGProgressView *) [cell viewWithTag:2];
            lifeBar.progress = ([self.tavern.questHP floatValue] / [self.quest.bossHp floatValue]);
        } else if (indexPath.item == 2) {
            UILabel *lifeLabel = (UILabel *) [cell viewWithTag:1];
            lifeLabel.text = [NSString stringWithFormat:@"Rage: %@ / %@", [self.tavern.questRage abbreviateNumber], [self.quest.bossRage abbreviateNumber]];
            lifeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            HRPGProgressView *rageBar = (HRPGProgressView *) [cell viewWithTag:2];
            rageBar.progress = ([self.tavern.questRage floatValue] / [self.quest.bossRage floatValue]);
        }
        return;
    }
    if (self.buttonIndex && self.buttonIndex.item == indexPath.item) {
        return;
    }
    ChatMessage *message;
    if (self.buttonIndex && self.buttonIndex.item < indexPath.item) {
        message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item-1 inSection:0]];
    } else {
        message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
    }
    UILabel *authorLabel = (UILabel *) [cell viewWithTag:1];
    authorLabel.text = message.user;
    authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    authorLabel.textColor = [message contributorColor];

    UITextView *textLabel = (UITextView *) [cell viewWithTag:2];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textLabel.delegate = self;
    cell.backgroundColor = [UIColor whiteColor];
    NSString *text = [message.text stringByReplacingEmojiCheatCodesWithUnicode];
    
    if (!([text rangeOfString:user.username].location == NSNotFound)) {
        cell.backgroundColor = [UIColor colorWithRed:0.474 green:1.000 blue:0.031 alpha:0.030];
    }
    
    if (text) {
        NSMutableAttributedString *attributedText = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:text];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] range:NSMakeRange(0, attributedText.length)];
        [attributedText ghf_applyAttributes:self.markdownAttributes];
        textLabel.attributedText = attributedText;
        
        double rowHeight = [attributedText boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil].size.height + 51;
        if (self.buttonIndex && self.buttonIndex.item < indexPath.item) {
            self.rowHeights[indexPath.item-1] = [NSNumber numberWithDouble:rowHeight];
        } else {
            self.rowHeights[indexPath.item] = [NSNumber numberWithDouble:rowHeight];
        }
    }
    UILabel *dateLabel = (UILabel *) [cell viewWithTag:3];
    dateLabel.text = [message.timestamp timeAgo];
    dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"MessageSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        HRPGMessageViewController *messageViewController = (HRPGMessageViewController*) navController.topViewController;
        if (self.replyMessage) {
            messageViewController.presetText = self.replyMessage;
            self.replyMessage = nil;
        }
    } else if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        HRPGUserProfileViewController *userProfileViewController = (HRPGUserProfileViewController*) segue.destinationViewController;
        userProfileViewController.userID = selectedMessage.userObject.id;
        userProfileViewController.username = selectedMessage.user;
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (IBAction)unwindToListSendMessage:(UIStoryboardSegue *)segue {
    HRPGMessageViewController *messageController = (HRPGMessageViewController*)[segue sourceViewController];
    [self addActivityCounter];
    [self.sharedManager chatMessage:messageController.messageView.text withGroup:@"habitrpg" onSuccess:^() {
        [self.sharedManager fetchGroup:@"habitrpg" onSuccess:^() {
            [self removeActivityCounter];
            [self fetchTavern];
        }                      onError:^() {
            [self removeActivityCounter];
            [self.sharedManager displayNetworkError];
        }];
        [self removeActivityCounter];
    }onError:^() {
        [self removeActivityCounter];
    }];
    
}

- (IBAction)showUserProfile:(id)sender {
    [self performSegueWithIdentifier:@"UserProfileSegue" sender:self];
}

- (IBAction)deleteMessage:(id)sender {
    //hide button cell again
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[self.buttonIndex] withRowAnimation:UITableViewRowAnimationTop];
    self.buttonIndex = nil;
    [self.tableView endUpdates];
    [self.sharedManager deleteMessage:selectedMessage withGroup:@"habitrpg" onSuccess:^() {
        selectedMessage = nil;
    } onError:^() {
    }];
}

- (IBAction)replyToMessage:(id)sender {
    self.replyMessage = [NSString stringWithFormat:@"@%@ ", selectedMessage.user];
    [self performSegueWithIdentifier:@"MessageSegue" sender:self];
    //hide button cell again
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[self.buttonIndex] withRowAnimation:UITableViewRowAnimationTop];
    self.buttonIndex = nil;
    [self.tableView endUpdates];
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
}

@end
