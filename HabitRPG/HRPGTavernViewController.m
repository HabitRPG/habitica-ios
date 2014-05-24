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

@interface HRPGTavernViewController ()
@property HRPGManager *sharedManager;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation HRPGTavernViewController
@synthesize managedObjectContext;
@dynamic sharedManager;
User *user;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    user = [self.sharedManager getUser];
}

- (void)refresh {
    [self.sharedManager fetchGroup:@"habitrpg" onSuccess:^() {
        [self.refreshControl endRefreshing];
    }                      onError:^() {
        [self.refreshControl endRefreshing];
        [self.sharedManager displayNetworkError];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1: {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
            return [sectionInfo numberOfObjects];
        }
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Inn", nil);
            break;
        case 1:
            return NSLocalizedString(@"Chat", nil);
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    } else {
        ChatMessage *message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        return [message.text boundingRectWithSize:CGSizeMake(250.0f, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{
                                               NSFontAttributeName : [UIFont systemFontOfSize:15.0f]
                                       }
                                          context:nil].size.height + 41;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *notificationColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
    if (indexPath.section == 0 && indexPath.item == 0) {
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
            [self.tableView reloadData];
        }                    onError:^() {

        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname;
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (user.sleep) {
            cellname = @"WakeupCell";
        } else {
            cellname = @"RestCell";
        }
    } else {
        if (indexPath.section) {
            cellname = @"ChatCell";
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if (indexPath.section == 1) {
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
    switch (type) {
        case NSFetchedResultsChangeInsert:
            newIndexPath = [NSIndexPath indexPathForItem:newIndexPath.item inSection:1];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:1];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:1];
            newIndexPath = [NSIndexPath indexPathForItem:newIndexPath.item inSection:1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
    UILabel *authorLabel = (UILabel *) [cell viewWithTag:1];
    authorLabel.text = message.user;
    authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    UILabel *textLabel = (UILabel *) [cell viewWithTag:2];
    textLabel.text = message.text;
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];


    UILabel *dateLabel = (UILabel *) [cell viewWithTag:3];
    dateLabel.text = [message.timestamp timeAgo];
    dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
