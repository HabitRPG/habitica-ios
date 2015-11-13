//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGTableViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGFormViewController.h"
#import "Tag.h"
#import "HRPGFilterViewController.h"
#import "HRPGTabBarController.h"
#import "HRPGNavigationController.h"
#import <POPSpringAnimation.h>
#import "NSString+Emoji.h"
#import "HRPGSearchDataManager.h"
#import "NSDate+DaysSince.h"

@interface HRPGTableViewController () <UISearchBarDelegate>
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property int extraCellSpacing;

@property (nonatomic, strong) UISearchBar *searchBar;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGTableViewController
Task *editedTask;
BOOL editable;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coachMarks = @[@"addTask", @"editTask", @"filterTask"];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    if (![HRPGSearchDataManager sharedManager].searchString) {
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + self.searchBar.frame.size.height);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeFilter:) name:@"taskFilterChanged"  object:nil];
    [self didChangeFilter:nil];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        //due to the way ipads are used we want to have a bit of extra spacing
        self.extraCellSpacing = 8;
    }
    self.dayStart = [[self.sharedManager getUser].dayStart integerValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![HRPGSearchDataManager sharedManager].searchString || [[HRPGSearchDataManager sharedManager].searchString isEqualToString:@""]) {
        self.searchBar.text = @"";
        [self.searchBar setShowsCancelButton: NO animated: YES];
    } else {
        self.searchBar.text = [HRPGSearchDataManager sharedManager].searchString;
    }
    
    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    [self.tableView reloadData];
}

- (void)refresh {
    if (self.openedIndexPath) {
        [self tableView:self.tableView expandTaskAtIndexPath:self.openedIndexPath];
    }
    [self.sharedManager fetchUser:^() {
        [self.refreshControl endRefreshing];
    }                     onError:^() {
        [self.refreshControl endRefreshing];
    }];
}

- (NSPredicate *)getPredicate {
    NSMutableArray *predicateArray = [[NSMutableArray alloc] initWithCapacity:3];
    HRPGTabBarController *tabBarController = (HRPGTabBarController*)self.tabBarController;
    
    [predicateArray addObjectsFromArray:[Task predicatesForTaskType:self.typeName withFilterType:self.filterType]];
    
    if ([tabBarController.selectedTags count] > 0) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"SUBQUERY(tags, $tag, $tag IN %@).@count = %d", tabBarController.selectedTags, [tabBarController.selectedTags count]]];
    }
    
    if ([HRPGSearchDataManager sharedManager].searchString) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"(text CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", [HRPGSearchDataManager sharedManager].searchString, [HRPGSearchDataManager sharedManager].searchString]];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
}

- (NSArray *)getSortDescriptors {
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    if ([_typeName isEqual:@"todo"]) {
        if (self.filterType == TaskToDoFilterTypeDated) {
            NSSortDescriptor *dueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"duedate" ascending:YES];
            return @[dueDescriptor, orderDescriptor, dateDescriptor];
        } else {
            return @[orderDescriptor, dateDescriptor];
        }
    } else {
        return @[orderDescriptor, dateDescriptor];
    }
}

- (void) didChangeFilter:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.filterType = [defaults integerForKey:[NSString stringWithFormat:@"%@Filter", self.typeName]];
    
    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    [self.fetchedResultsController.fetchRequest setSortDescriptors:[self getSortDescriptors]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
    
    NSInteger filterCount = 0;
    if (self.filterType != 0) {
        filterCount++;
    }
    HRPGTabBarController *tabBarController = (HRPGTabBarController*)self.tabBarController;
    filterCount += tabBarController.selectedTags.count;
    
    if (filterCount == 0) {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Filter", nil);
    } else if (filterCount == 1) {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"1 Filter", nil);
    } else {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:NSLocalizedString(@"%ld Filters", @"more than one filter"), (long)filterCount];
    }
}


- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier {
    if ([coachMarkIdentifier isEqualToString:@"addTask"]) {
        return CGRectMake(self.view.frame.size.width-47, 19, 44, 44);
    } else if ([coachMarkIdentifier isEqualToString:@"editTask"]) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
            
            UITableViewCell *cell;
            for (NSIndexPath *indexPath in visibleCells) {
                cell = [self.tableView cellForRowAtIndexPath:indexPath];
                CGRect frame = [self.tableView convertRect:cell.frame toView:self.parentViewController.parentViewController.view];
                if (frame.origin.y >= self.tableView.contentInset.top) {
                    return frame;
                }
            }
            return [self.tableView convertRect:cell.frame toView:self.parentViewController.parentViewController.view];
        }
    } else if ([coachMarkIdentifier isEqualToString:@"filterTask"]) {
        NSInteger width = [self.navigationItem.leftBarButtonItem.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                                                    attributes:@{
                                                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:17.0]
                                                                                                                 }
                                                                                                       context:nil].size.width;
        return CGRectMake(5, 20, width+6, 44);
    }
    return CGRectZero;
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"addTask"]) {
        return @{@"text": NSLocalizedString(@"Tap to add a new task.", nil)};
    } else if ([tutorialIdentifier isEqualToString:@"editTask"]) {
        return @{@"text": NSLocalizedString(@"Tap a task to edit it. Swipe left to delete it.", nil)};
    } else if ([tutorialIdentifier isEqualToString:@"filterTask"]) {
        return @{@"text": NSLocalizedString(@"Tap to filter tasks.", nil)};
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.fetchedResultsController sections].count == 0) {
        return 0;
    }
    if (section > [self.fetchedResultsController sections].count-1) {
        return 1;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        if (self.openedIndexPath.section != section) {
            return [sectionInfo numberOfObjects];
        } else {
            return [sectionInfo numberOfObjects] + self.indexOffset;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section > [self.fetchedResultsController sections].count-1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
        return cell;
    }
    
    NSString *cellname = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !(self.openedIndexPath.item + self.indexOffset >= indexPath.item && self.openedIndexPath.item < indexPath.item && self.indexOffset > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        if (editingStyle == UITableViewCellEditingStyleDelete) {
            Task *task = [self taskAtIndexPath:indexPath];
            [self.sharedManager deleteTask:task onSuccess:^() {
            }                      onError:^() {

            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > [self.fetchedResultsController sections].count-1) {
        return 44;
    }
    
    Task *task = [self taskAtIndexPath:indexPath];
    
    //TODO: if we find a way to filter due dailies in predicate remove this
    if ([task.type isEqualToString:@"daily"] && indexPath.item+1 < [self.fetchedResultsController fetchedObjects].count && ((self.filterType == TaskDailyFilterTypeDue && ![task dueTodayWithOffset:self.dayStart]) || (self.filterType == TaskDailyFilterTypeGrey && [task dueTodayWithOffset:self.dayStart] && ![task.completed boolValue]))) {
        return 0.1;
    }
    float width;
    NSInteger height = 35;
    if ([task.checklist count] > 0) {
        width = self.viewWidth - 125;
    } else {
        width = self.viewWidth - 94;
    }
    height = height + [[task.text stringByReplacingEmojiCheatCodesWithUnicode] boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                            }
                                                                                            context:nil].size.height;
    if (task.notes) {
        NSInteger notesHeight = [[task.notes stringByReplacingEmojiCheatCodesWithUnicode] boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                                                            options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                                         attributes:@{
                                                                                                      NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]
                                                                                                      }
                                                                                            context:nil].size.height;
        if (notesHeight < [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].lineHeight*3) {
            height = height + notesHeight;
        } else {
            height = height + [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].lineHeight*3;
        }
    }
    
    if ([task.type isEqualToString:@"daily"] && [task.streak integerValue] > 0) {
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Current streak: %@", nil), task.streak];
        height = height + [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                                                    attributes:@{
                                                                                                                 NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]
                                                                                                                 }
                                                                                                       context:nil].size.height;
    } else if ([task.type isEqualToString:@"todo"]) {
        height = height + [@"" boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                          attributes:@{
                                                       NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]
                                                       }
                                             context:nil].size.height;
    }

    
    height = height + self.extraCellSpacing;
    if (task.duedate) {
        height = height + 5;
    }
    if (height <= 70) {
        return 70;
    }
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return !(self.openedIndexPath.item + self.indexOffset >= indexPath.item && self.openedIndexPath.item < indexPath.item && self.indexOffset > 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == self.openedIndexPath || (self.indexOffset > 0 && indexPath.item > self.openedIndexPath.item && indexPath.item < (self.openedIndexPath.item+self.indexOffset))) {
        indexPath = [self indexPathForTaskWithOffset:indexPath];
        [self tableView:tableView expandTaskAtIndexPath:self.openedIndexPath];
    }
    editedTask = [self taskAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"FormSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"UnwindTagSegue"]) {
        HRPGFilterViewController *tagViewController = (HRPGFilterViewController*)segue.sourceViewController;
        HRPGTabBarController *tabBarController = (HRPGTabBarController*)self.tabBarController;
        tabBarController.selectedTags = tagViewController.selectedTags;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"taskFilterChanged" object:nil];
    }
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGFormViewController *formViewController = (HRPGFormViewController *) segue.sourceViewController;
    if (formViewController.editTask) {
        [self.sharedManager updateTask:formViewController.task onSuccess:nil onError:nil];
    } else {
        [self.sharedManager createTask:formViewController.task onSuccess:nil onError:nil];
    }
}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[self getPredicate]];
    
    [fetchRequest setSortDescriptors:[self getSortDescriptors]];

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
            if (self.openedIndexPath) {
                [self tableView:tableView expandTaskAtIndexPath:self.openedIndexPath];
            }
            [tableView insertRowsAtIndexPaths:@[[self indexPathWithOffset:newIndexPath]] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete: {
            if (self.openedIndexPath) {
                if (indexPath.section == self.openedIndexPath.section && indexPath.item == self.openedIndexPath.item) {
                    [tableView deleteRowsAtIndexPaths:[self checklistitemIndexPathsWithOffset:self.indexOffset atIndexPath:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    self.openedIndexPath = nil;
                    self.indexOffset = 0;
                }
            }
            [tableView deleteRowsAtIndexPaths:@[[self indexPathWithOffset:indexPath]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:[self indexPathWithOffset:indexPath]] atIndexPath:[self indexPathWithOffset:indexPath] withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            if (indexPath.item == newIndexPath.item) {
                return;
            }
            if (self.openedIndexPath) {
                [self tableView:tableView expandTaskAtIndexPath:self.openedIndexPath];
            }
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell.contentView respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell.contentView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
}


- (UIView *)viewWithIcon:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void) tableView:(UITableView *)tableView expandTaskAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > [self.fetchedResultsController sections].count-1) {
        return;
    }
    
    if (indexPath.section == 1) {
        return;
    }
    
    if (self.openedIndexPath != nil && self.openedIndexPath.item == indexPath.item) {
        NSIndexPath *tempPath = self.openedIndexPath;
        int tempIndexOffset = self.indexOffset;
        self.openedIndexPath = nil;
        self.indexOffset = 0;
        [self configureCell:[tableView cellForRowAtIndexPath:tempPath] atIndexPath:tempPath withAnimation:YES];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[self checklistitemIndexPathsWithOffset:tempIndexOffset atIndexPath:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        self.indexOffset = 0;
        [self.tableView endUpdates];
    } else {
        if (self.openedIndexPath) {
            if (indexPath.section == self.openedIndexPath.section && indexPath.item > self.openedIndexPath.item) {
                indexPath = [NSIndexPath indexPathForItem:indexPath.item-self.indexOffset inSection:indexPath.section];
            }
            [self.tableView beginUpdates];
            [self tableView:tableView expandTaskAtIndexPath:self.openedIndexPath];
            [self.tableView endUpdates];
        }
        
        Task *task = [self taskAtIndexPath:indexPath];
        if ([task.checklist count] > 0) {
            self.openedIndexPath = indexPath;
            self.indexOffset = (int) [task.checklist count];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:YES];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[self checklistitemIndexPathsWithOffset:self.indexOffset atIndexPath:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:indexPath.item+self.indexOffset inSection:indexPath.section];
            if (![self isIndexPathVisible:lastIndexPath]) {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
}

- (NSIndexPath*)indexPathForTaskWithOffset:(NSIndexPath*) indexPath {
    if (self.openedIndexPath.item + self.indexOffset < indexPath.item && self.indexOffset > 0) {
        return [NSIndexPath indexPathForItem:indexPath.item - self.indexOffset inSection:indexPath.section];
    } else if (self.openedIndexPath.item + self.indexOffset >= indexPath.item && self.openedIndexPath.item < indexPath.item && self.indexOffset > 0) {
        return self.openedIndexPath;
    } else {
        return indexPath;
    }
}

- (NSIndexPath*)indexPathWithOffset:(NSIndexPath*) indexPath {
    if (self.openedIndexPath.item < indexPath.item) {
        return [NSIndexPath indexPathForItem:indexPath.item + self.indexOffset inSection:indexPath.section];
    } else {
        return indexPath;
    }
}

- (Task*)taskAtIndexPath:(NSIndexPath*)indexPath {
    if (self.openedIndexPath.item + self.indexOffset < indexPath.item && self.indexOffset > 0) {
        indexPath = [NSIndexPath indexPathForItem:indexPath.item - self.indexOffset inSection:indexPath.section];
    } else if (self.openedIndexPath.item + self.indexOffset >= indexPath.item && self.openedIndexPath.item < indexPath.item && self.indexOffset > 0) {
        indexPath = self.openedIndexPath;
    }
    if (self.fetchedResultsController.sections.count > indexPath.section) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
        if ([sectionInfo numberOfObjects] > indexPath.item) {
            return [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    return nil;
}

- (NSArray*)checklistitemIndexPathsWithOffset:(NSInteger)offset atIndexPath:(NSIndexPath*)indexPath {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 1; i <= offset; i++) {
        [array addObject:[NSIndexPath indexPathForItem:indexPath.item + i inSection:indexPath.section]];
    }
    return array;
}

- (NSArray*)checklistitemIndexPathsForTask:(Task*)task atIndexPath:(NSIndexPath*)indexPath {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 1; i <= task.checklist.count; i++) {
        [array addObject:[NSIndexPath indexPathForItem:indexPath.item + i inSection:indexPath.section]];
    }
    return array;
}

#pragma mark - Search
- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [HRPGSearchDataManager sharedManager].searchString = searchText;
    
    if ([[HRPGSearchDataManager sharedManager].searchString isEqualToString:@""]) {
        [HRPGSearchDataManager sharedManager].searchString = nil;
    }
    
    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton: NO animated: YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton: NO animated: YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = @"";
    [searchBar setShowsCancelButton: NO animated: YES];
    
    [HRPGSearchDataManager sharedManager].searchString = nil;
    
    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    [searchBar resignFirstResponder];
    
    [self.tableView reloadData];
}

- (void) scrollToTaskWithId:(NSString *)taskID {
    NSInteger index = 0;
    NSIndexPath *indexPath;
    for (Task *task in self.fetchedResultsController.fetchedObjects) {
        if ([task.id isEqualToString:taskID]) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        }
        index++;
    }
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FormSegue"]) {
        HRPGNavigationController *destViewController = segue.destinationViewController;
        destViewController.sourceViewController = self;
        
        HRPGFormViewController *formController = (HRPGFormViewController *) destViewController.topViewController;
        formController.readableTaskType = self.readableName;
        HRPGTabBarController *tabBarController = (HRPGTabBarController*) self.tabBarController;
        formController.activeTags = tabBarController.selectedTags;
        formController.taskType = self.typeName;
        if (editedTask) {
            formController.task = editedTask;
            formController.editTask = YES;
            editedTask = nil;
        }
    } else if ([segue.identifier isEqualToString:@"FilterSegue"]) {
        HRPGTabBarController *tabBarController = (HRPGTabBarController*)self.tabBarController;
        HRPGNavigationController *navigationController = (HRPGNavigationController *) segue.destinationViewController;
        navigationController.sourceViewController = self;
        HRPGFilterViewController *filterController = (HRPGFilterViewController *) navigationController.topViewController;
        filterController.selectedTags = [tabBarController.selectedTags mutableCopy];
        filterController.taskType = self.typeName;
    }
}

@end
