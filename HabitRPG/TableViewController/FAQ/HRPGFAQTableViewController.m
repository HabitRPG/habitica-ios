//
//  HRPGFAQTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGFAQTableViewController.h"
#import "FAQ.h"
#import "HRPGFAQDetailViewController.h"

@interface HRPGFAQTableViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation HRPGFAQTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FAQ *faq = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat width = self.viewWidth - 51;
    
    CGFloat height =  [faq.question boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                         NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                                         }
                                               context:nil].size.height;
    height = height + 32;
    return height;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[indexDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
    }
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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:YES];
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    FAQ *faq = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = faq.question;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FAQDetailSegue"]) {
        HRPGFAQDetailViewController *detailViewController = (HRPGFAQDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        FAQ *faq = [self.fetchedResultsController objectAtIndexPath:indexPath];
        detailViewController.faq = faq;
    }
}

#pragma mark - Search
- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"question CONTAINS[cd] %@", searchText];
    
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton: NO animated: YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton: NO animated: YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [searchBar setShowsCancelButton: NO animated: YES];
    
    [self.fetchedResultsController.fetchRequest setPredicate:nil];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    [searchBar resignFirstResponder];
    
    [self.tableView reloadData];
}

@end
