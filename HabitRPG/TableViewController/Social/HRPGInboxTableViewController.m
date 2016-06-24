//
//  HRPGInboxTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGInboxTableViewController.h"
#import "InboxMessage.h"
#import "HRPGInboxChatViewController.h"

@interface HRPGInboxTableViewController ()

@property NSArray<InboxMessage *> *inboxMessages;

@end

@implementation HRPGInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self rebuildMessageList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.sharedManager markInboxSeen:nil onError:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inboxMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InboxMessage"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[ timestampSortDescriptor,  ];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use
        // this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self rebuildMessageList];
    [self.tableView reloadData];
}

- (void)rebuildMessageList {
    NSMutableArray *userIDList = [[NSMutableArray alloc] init];
    NSMutableArray *inboxMessages = [[NSMutableArray alloc] init];
    for (InboxMessage *message in self.fetchedResultsController.fetchedObjects) {
        if (![userIDList containsObject:message.userID]) {
            [userIDList addObject:message.userID];
            [inboxMessages addObject:message];
        }
    }
    self.inboxMessages = inboxMessages;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    InboxMessage *message = [self.inboxMessages objectAtIndex:indexPath.item];
    cell.textLabel.text = message.username;
    cell.detailTextLabel.text = message.text;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChatSegue"]) {
        HRPGInboxChatViewController *chatViewController = (HRPGInboxChatViewController *)segue.destinationViewController;
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        InboxMessage *message = [self.inboxMessages objectAtIndex:indexPath.item];
        chatViewController.userID = message.userID;
        chatViewController.username = message.username;
    }
}

@end
