//
//  HRPGGuildsOverviewViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 05/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGGuildsOverviewViewController.h"
#import "HRPGGroupTableViewController.h"
#import "NSString+Emoji.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGGuildsOverviewViewController ()

@property User *user;
@property(nonatomic) NSArray *suggestedGuilds;

@property BOOL fetchedGuilds;

@end

@implementation HRPGGuildsOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor purple400];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self refresh];
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchGroups:@"guilds"
        onSuccess:^() {
            [self.refreshControl endRefreshing];
        }
        onError:^() {
            [self.refreshControl endRefreshing];
        }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.suggestedGuilds.count > 0) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        id<NSFetchedResultsSectionInfo> sectionInfo =
        [self.fetchedResultsController sections][(NSUInteger)section];
        return [sectionInfo numberOfObjects];
    } else if (section == 1) {
        return 1;
    } else {
        return [self suggestedGuilds].count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"My Guilds", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Public Guilds", nil);
    } else {
        return NSLocalizedString(@"Suggested Guilds", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return [self.tableView dequeueReusableCellWithIdentifier:@"PublicGuildsCell"
                                                    forIndexPath:indexPath];
    } else {
        UITableViewCell *cell =
            [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        if (indexPath.section == 0) {
            [self configureCell:cell atIndexPath:indexPath];
        } else {
            cell.textLabel.text = ((Group *)[self suggestedGuilds][indexPath.item]).name;
        }

        return cell;
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest
        setPredicate:[NSPredicate predicateWithFormat:
                                      @"type == 'guild' && isMember==YES && id != 'habitrpg'"]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
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

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.suggestedGuilds.count > 0 && self.tableView.numberOfSections == 2) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (self.suggestedGuilds.count == 0 && self.tableView.numberOfSections == 3) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

- (id)guildAtIndexPath:(NSIndexPath *)indexPath {
    id item  = nil;
    if ([[self.fetchedResultsController sections] count] > [indexPath section]){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
        if ([sectionInfo numberOfObjects] > [indexPath row]){
            item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    return item;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Group *guild = [self guildAtIndexPath:indexPath];
    UILabel *titleLabel = [cell viewWithTag:1];
    titleLabel.text = [guild.name stringByReplacingEmojiCheatCodesWithUnicode];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    if ([segue.identifier isEqualToString:@"ShowGuildSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        SplitSocialViewController *tableviewController = segue.destinationViewController;
        if (indexPath.section == 0) {
            Group *guild = [self.fetchedResultsController objectAtIndexPath:indexPath];
            tableviewController.groupID = guild.id;
        } else {
            Group *guild = self.suggestedGuilds[indexPath.item];
            tableviewController.groupID = guild.id;
        }
    }
}

- (NSArray *)suggestedGuilds {
    if ([self.fetchedResultsController fetchedObjects].count >= 3) {
        return nil;
    }

    if (_suggestedGuilds != nil) {
        return _suggestedGuilds;
    }

    NSMutableArray *guilds = [NSMutableArray array];
    NSMutableArray *memberGuildIds = [NSMutableArray array];
    for (Group *guild in [self.fetchedResultsController fetchedObjects]) {
        [memberGuildIds addObject:guild.id];
    }

    if (![memberGuildIds containsObject:@"5481ccf3-5d2d-48a9-a871-70a7380cee5a"]) {
        [guilds addObject:@"5481ccf3-5d2d-48a9-a871-70a7380cee5a"];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"partyID"] &&
        ![memberGuildIds containsObject:@"f2db2a7f-13c5-454d-b3ee-ea1f5089e601"]) {
        [guilds addObject:@"f2db2a7f-13c5-454d-b3ee-ea1f5089e601"];
    }

    NSDictionary *taskGroups = @{
        @"work" : @[ @"cf0a9cb8-606e-4bf0-bcad-f9b1715b8819" ],
        @"exercise" : @[],
        @"healthWellness" : @[ @"b422b8a5-8d66-4197-9f91-d4edb8610264" ],
        @"school" : @[ @"82fe50b1-4fa5-4e94-8114-aa66516c0d9d" ],
        @"teams" : @[],
        @"chores" : @[],
        @"creativity" : @[ @"dea7a124-9e69-4163-a708-d3e961a96159" ],
    };

    for (ImprovementCategory *category in self.user.preferences.improvementCategories) {
        NSArray *guildsList = taskGroups[category.identifier];
        for (NSString *guildID in guildsList) {
            if (![memberGuildIds containsObject:guildID]) {
                [guilds addObject:guildID];
            }
        }
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest
        setPredicate:[NSPredicate predicateWithFormat:@"type == 'guild' && id IN %@", guilds]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSError *error;
    _suggestedGuilds = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (_suggestedGuilds.count < guilds.count && !self.fetchedGuilds) {
        [[HRPGManager sharedManager] fetchGroups:@"publicGuilds"
                              onSuccess:^() {
                                  self.fetchedGuilds = YES;
                                  _suggestedGuilds = nil;
                                  if ([self.tableView numberOfSections] != [self numberOfSectionsInTableView:self.tableView]) {
                                      if ([self.tableView numberOfSections] < 3) {
                                          [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                                      } else {
                                          [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                                      }
                                  } else {
                                      if ([self numberOfSectionsInTableView:self.tableView] == 3) {
                                          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                                      }
                                  }
                                  
                              }
                                onError:nil];
    }

    return _suggestedGuilds;
}

@end
