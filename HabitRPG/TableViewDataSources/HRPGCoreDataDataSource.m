//
//  HRPGCoreDataDataSource.m
//  Habitica
//
//  Created by Phillip Thelen on 05/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCoreDataDataSource.h"

@interface HRPGCoreDataDataSource ()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) FetchRequestConfigureBlock fetchRequestBlock;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic) UILabel *emptyLabel;
@end

@implementation HRPGCoreDataDataSource

- (id)init {
    return nil;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        entityName:(NSString *)entityName
                    cellIdentifier:(NSString *)cellIdentifier
                configureCellBlock:(TableViewCellConfigureBlock)configureCellBlock
                 fetchRequestBlock:(FetchRequestConfigureBlock)fetchRequestBlock
                     asDelegateFor:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.managedObjectContext = managedObjectContext;
        self.entityName = entityName;
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = [configureCellBlock copy];
        self.fetchRequestBlock = fetchRequestBlock;
        self.tableView = tableView;
        self.tableView.dataSource = self;
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    if (self.fetchRequestBlock) {
        self.fetchRequestBlock(fetchRequest);
    }
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:self.sectionNameKeyPath
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

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    id item  = nil;
    if ([[self.fetchedResultsController sections] count] > [indexPath section]){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
        if ([sectionInfo numberOfObjects] > [indexPath row]){
            item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    return item;
}

- (id)cellAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)reconfigureFetchRequest {
    if (self.fetchRequestBlock) {
        self.fetchRequestBlock(self.fetchedResultsController.fetchRequest);
    }
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSections {
    return [self.fetchedResultsController sections].count;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sectionNameKeyPath && !self.haveEmptyHeaderTitles) {
        return [[self.fetchedResultsController sections][(NSUInteger)section] name];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    if (sections.count == 0) {
        return 0;
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[(NSUInteger)section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL b = [self.delegate canEditRowAtIndexPath:indexPath];
    return b;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.delegate deleteItemAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    NSString *cellIdentifier = self.cellIdentifier;
    if (self.cellIdentifierBlock) {
        cellIdentifier = self.cellIdentifierBlock(item, indexPath);
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item, indexPath);
    }
    return cell;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
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
            
        case NSFetchedResultsChangeUpdate: {
            id item = [self itemAtIndexPath:indexPath];
            if (self.configureCellBlock) {
                self.configureCellBlock([tableView cellForRowAtIndexPath:indexPath], item, indexPath);
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
    
    if (self.emptyText) {
        [self configureEmptyLabel];
    }
    
    if (self.controllerDidChangeContent) {
        self.controllerDidChangeContent();
    }
}

- (void)configureEmptyLabel {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0 && self.emptyLabel == nil) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
        emptyLabel.text = self.emptyText;
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.textColor = [UIColor lightGrayColor];
        emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.tableView addSubview:emptyLabel];
    } else if ([[self.fetchedResultsController fetchedObjects] count] > 0 && self.emptyLabel) {
        [self.emptyLabel removeFromSuperview];
    }
}

- (NSArray *)items {
    return self.fetchedResultsController.fetchedObjects;
}

@end
