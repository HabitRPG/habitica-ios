//
//  HRPGPublicGuildsViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 05/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGPublicGuildsViewController.h"
#import "HRPGPublicGuildTableViewCell.h"
#import "HRPGGroupTableViewController.h"

@interface HRPGPublicGuildsViewController ()

@end

@implementation HRPGPublicGuildsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self refresh];
}

- (void)refresh {
    [self.sharedManager fetchGroups:@"public" onSuccess:^() {
        [self.refreshControl endRefreshing];
    }                      onError:^() {
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController fetchedObjects].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:(HRPGPublicGuildTableViewCell *)cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Group *guild = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat width = self.viewWidth - 24;
    CGFloat titleWidth = width - [[NSString stringWithFormat:NSLocalizedString(@"%@ Members", nil), guild.memberCount] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                                                                                                                        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                                                                                                                                                                                                                        } context:nil].size.width;
    CGFloat height = 20 + [guild.name boundingRectWithSize:CGSizeMake(titleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                                                     NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                                                                                                                                     } context:nil].size.height;
    height = height + [guild.hdescription boundingRectWithSize:CGSizeMake(titleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                                                       NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                                                                                                                       } context:nil].size.height;
    return height;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type == 'guild'"]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"memberCount" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"publicGuilds"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(HRPGPublicGuildTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void) configureCell:(HRPGPublicGuildTableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath {
    Group *guild = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureForGuild:guild];
    cell.joinAction = ^() {
        [self.sharedManager joinGroup:guild.id withType:guild.type onSuccess:nil onError:nil];
    };
    cell.leaveAction = ^() {
        [self.sharedManager leaveGroup:guild withType:guild.type onSuccess:nil onError:nil];
    };
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowGuildSegue"]) {
        UITableViewCell *cell = (UITableViewCell *) sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Group *guild = [self.fetchedResultsController objectAtIndexPath:indexPath];
        HRPGGroupTableViewController *guildViewController = (HRPGGroupTableViewController *)segue.destinationViewController;
        guildViewController.groupID = guild.id;
    }
}

@end
