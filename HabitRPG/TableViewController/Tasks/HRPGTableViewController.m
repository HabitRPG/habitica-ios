//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGTableViewController.h"
#import "HRPGFilterViewController.h"
#import "HRPGFormViewController.h"
#import "HRPGNavigationController.h"
#import "HRPGSearchDataManager.h"
#import "HRPGTabBarController.h"
#import "NSString+Emoji.h"
#import <POP/POP.h>
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGTableViewController ()<UISearchBarDelegate, UITableViewDragDelegate, UITableViewDropDelegate>
@property NSString *readableName;
@property NSString *typeName;
@property int extraCellSpacing;

@property(nonatomic, strong) UISearchBar *searchBar;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate;

@property BOOL userDrivenDataUpdate;
@property NSTimer *scrollTimer;
@property CGFloat autoScrollSpeed;
@property Task *movedTask;

@property NSMutableDictionary *heightAtIndexPath;
@end

@implementation HRPGTableViewController
Task *editedTask;
BOOL editable;
NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:[self getCellNibName] bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    self.coachMarks = @[ @"addTask", @"editTask", @"filterTask", @"reorderTask" ];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor purple400];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 48)];
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.backgroundColor = [UIColor gray500];
    self.tableView.tableHeaderView = self.searchBar;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeFilter:)
                                                 name:@"taskFilterChanged"
                                               object:nil];
    [self didChangeFilter:nil];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // due to the way ipads are used we want to have a bit of extra spacing
        self.extraCellSpacing = 8;
    }
    self.dayStart = [[[HRPGManager sharedManager] getUser].preferences.dayStart integerValue];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.dragDelegate = self;
        self.tableView.dropDelegate = self;
        [self.tableView setDragInteractionEnabled:YES];
    } else {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [self.tableView addGestureRecognizer:longPress];
    }
    
    self.heightAtIndexPath = [NSMutableDictionary new];
}

- (NSString *)getCellNibName {
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![HRPGSearchDataManager sharedManager].searchString ||
        [[HRPGSearchDataManager sharedManager].searchString isEqualToString:@""]) {
        self.searchBar.text = @"";
        [self.searchBar setShowsCancelButton:NO animated:YES];
    } else {
        self.searchBar.text = [HRPGSearchDataManager sharedManager].searchString;
    }

    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Add %@", nil), self.readableName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scrollToTaskAfterLoading) {
        [self scrollToTaskWithId:self.scrollToTaskAfterLoading];
        self.scrollToTaskAfterLoading = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self.heightAtIndexPath objectForKey:indexPath];
    if(height) {
        return height.floatValue;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (IBAction)longPressGestureRecognized:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                snapshot = [self customSnapshoFromView:cell];
                
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.25 initialSpringVelocity:0.75 options:0 animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.075, 1.075);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                } completion:^(BOOL finished) {
                    cell.hidden = YES;
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                self.userDrivenDataUpdate = YES;
                Task *sourceTask = [self taskAtIndexPath:sourceIndexPath];
                Task *task = [self taskAtIndexPath:indexPath];
                NSNumber *sourceOrder = sourceTask.order;
                sourceTask.order = task.order;
                task.order = sourceOrder;
                
                NSError *error;
                [self.managedObjectContext save:&error];
                
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath = indexPath;
                self.userDrivenDataUpdate = NO;
            }
            
            CGFloat positionInTableView = [self.view convertPoint:center fromView:snapshot.superview].y - self.tableView.contentOffset.y;
            CGFloat bottomThreshhold = self.tableView.frame.size.height - 120;
            CGFloat topThreshhold = self.tableView.frame.origin.y + 120;
            if (positionInTableView > bottomThreshhold) {
                if (self.autoScrollSpeed == 0) {
                    [self startAutoScrolling];
                }
                self.autoScrollSpeed = ((positionInTableView-bottomThreshhold)/120) * 10;
                
            } else if (positionInTableView < topThreshhold) {
                if (self.autoScrollSpeed == 0) {
                    [self startAutoScrolling];
                }
                self.autoScrollSpeed = ((positionInTableView-topThreshhold)/120) * 10;
            } else {
                self.autoScrollSpeed = 0;
            }
            
            break;
        }
            
        default: {
            Task *task = [self taskAtIndexPath:sourceIndexPath];
            [[HRPGManager sharedManager] moveTask:task toPosition:task.order onSuccess:nil onError:nil];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.alpha = 0.0;
            
            [snapshot pop_removeAllAnimations];
            POPSpringAnimation *centerAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            centerAnim.toValue = [NSValue valueWithCGPoint:cell.center];
            centerAnim.springSpeed = 10;
            centerAnim.springBounciness = 6;
            POPSpringAnimation *scaleAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
            scaleAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
            scaleAnim.springBounciness = 6;
            scaleAnim.springSpeed = 10;
            POPSpringAnimation *shadowAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerShadowOpacity];
            shadowAnim.toValue = @(0.0);
            
            centerAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                cell.alpha = 1.0;
                cell.hidden = NO;
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                self.autoScrollSpeed = 0;
            };
            
            [snapshot pop_addAnimation:centerAnim forKey:kPOPViewCenter];
            [snapshot pop_addAnimation:scaleAnim forKey:kPOPViewScaleXY];
            [snapshot.layer pop_addAnimation:shadowAnim forKey:kPOPLayerShadowOpacity];
            
            [UIView animateWithDuration:2.0 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:0 animations:^{
                
                snapshot.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
                
            }];
            
            break;
        }
    }
}

- (void)refresh {
    __weak HRPGTableViewController *weakSelf = self;
    [[HRPGManager sharedManager] fetchUser:^() {
        [weakSelf.refreshControl endRefreshing];
    } onError:^() {
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (NSPredicate *)getPredicate {
    NSMutableArray *predicateArray = [[NSMutableArray alloc] initWithCapacity:3];
    HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;

    [predicateArray addObjectsFromArray:[Task predicatesForTaskType:self.typeName
                                                     withFilterType:self.filterType withOffset:self.dayStart]];

    if ([tabBarController.selectedTags count] > 0) {
        [predicateArray
            addObject:[NSPredicate
                          predicateWithFormat:@"SUBQUERY(tags, $tag, $tag IN %@).@count = %d",
                                              tabBarController.selectedTags,
                                              [tabBarController.selectedTags count]]];
    }

    if ([HRPGSearchDataManager sharedManager].searchString) {
        [predicateArray
            addObject:[NSPredicate
                          predicateWithFormat:@"(text CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)",
                                              [HRPGSearchDataManager sharedManager].searchString,
                                              [HRPGSearchDataManager sharedManager].searchString]];
    }

    return [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
}

- (NSArray *)getSortDescriptors {
    NSSortDescriptor *orderDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *dateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    if ([_typeName isEqual:@"todo"]) {
        if (self.filterType == TaskToDoFilterTypeDated) {
            NSSortDescriptor *dueDescriptor =
                [[NSSortDescriptor alloc] initWithKey:@"duedate" ascending:YES];
            return @[ dueDescriptor, orderDescriptor, dateDescriptor ];
        } else {
            return @[ orderDescriptor, dateDescriptor ];
        }
    } else {
        return @[ orderDescriptor, dateDescriptor ];
    }
}

- (void)didChangeFilter:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.filterType =
        [defaults integerForKey:[NSString stringWithFormat:@"%@Filter", self.typeName]];

    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    [self.fetchedResultsController.fetchRequest setSortDescriptors:[self getSortDescriptors]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];

    NSInteger filterCount = 0;
    if (self.filterType != 0) {
        filterCount++;
    }
    HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;
    filterCount += tabBarController.selectedTags.count;

    if (filterCount == 0) {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Filter", nil);
    } else if (filterCount == 1) {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"1 Filter", nil);
    } else {
        self.navigationItem.leftBarButtonItem.title =
            [NSString stringWithFormat:NSLocalizedString(@"%ld Filters", @"more than one filter"),
                                       (long)filterCount];
    }
}

- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier {
    if ([coachMarkIdentifier isEqualToString:@"addTask"]) {
        return CGRectMake(self.view.frame.size.width - 47, 19, 44, 44);
    } else if ([coachMarkIdentifier isEqualToString:@"editTask"]) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];

            UITableViewCell *cell;
            for (NSIndexPath *indexPath in visibleCells) {
                cell = [self.tableView cellForRowAtIndexPath:indexPath];
                CGRect frame = [self.tableView
                    convertRect:cell.frame
                         toView:self.parentViewController.parentViewController.view];
                if (frame.origin.y >= self.tableView.contentInset.top) {
                    return frame;
                }
            }
            return [self.tableView convertRect:cell.frame
                                        toView:self.parentViewController.parentViewController.view];
        }
    } else if ([coachMarkIdentifier isEqualToString:@"filterTask"]) {
        NSInteger width = [self.navigationItem.leftBarButtonItem.title
                              boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin |
                                                   NSStringDrawingUsesFontLeading
                                        attributes:@{
                                            NSFontAttributeName : [UIFont systemFontOfSize:17.0]
                                        }
                                           context:nil]
                              .size.width;
        return CGRectMake(5, 20, width + 6, 44);
    } else if ([coachMarkIdentifier isEqualToString:@"reorderTask"]) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
            
            UITableViewCell *cell;
            for (NSIndexPath *indexPath in visibleCells) {
                cell = [self.tableView cellForRowAtIndexPath:indexPath];
                CGRect frame = [self.tableView
                                convertRect:cell.frame
                                toView:self.parentViewController.parentViewController.view];
                if (frame.origin.y >= self.tableView.contentInset.top) {
                    return frame;
                }
            }
            return [self.tableView convertRect:cell.frame
                                        toView:self.parentViewController.parentViewController.view];
        }
    }
    return CGRectZero;
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"addTask"]) {
        return @{ @"text" : NSLocalizedString(@"Tap to add a new task.", nil) };
    } else if ([tutorialIdentifier isEqualToString:@"editTask"]) {
        return @{
            @"text" : NSLocalizedString(
                @"Tap a task to edit it and add reminders. Swipe left to delete it.", nil)
        };
    } else if ([tutorialIdentifier isEqualToString:@"filterTask"]) {
        return @{ @"text" : NSLocalizedString(@"Tap to filter tasks.", nil) };
    } else if ([tutorialIdentifier isEqualToString:@"reorderTask"]) {
        return @{@"text" : NSLocalizedString(@"Hold down on a task to drag it around.", nil)};
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
    return [[self.fetchedResultsController sections][section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > [self.fetchedResultsController sections].count - 1) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
        return cell;
    }

    NSString *cellname = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = [self taskAtIndexPath:indexPath];
        [[HRPGManager sharedManager] deleteTask:task
            onSuccess:nil onError:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    editedTask = [self taskAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"FormSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"UnwindTagSegue"]) {
        HRPGFilterViewController *tagViewController = segue.sourceViewController;
        HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;
        tabBarController.selectedTags = tagViewController.selectedTags;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"taskFilterChanged" object:nil];
    }
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGFormViewController *formViewController = segue.sourceViewController;
    if (formViewController.editTask) {
        [[HRPGManager sharedManager] updateTask:formViewController.task onSuccess:nil onError:nil];
    } else {
        [[HRPGManager sharedManager] createTask:formViewController.task onSuccess:nil onError:nil];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[self getPredicate]];

    [fetchRequest setSortDescriptors:[self getSortDescriptors]];

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
    if (self.userDrivenDataUpdate) return;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
    if (self.userDrivenDataUpdate) return;
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
    if (self.userDrivenDataUpdate) return;
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }

        case NSFetchedResultsChangeUpdate:
            [self
                configureCell:[tableView cellForRowAtIndexPath:indexPath]
                  atIndexPath:indexPath
                withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            if (indexPath.item == newIndexPath.item) {
                return;
            }
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.userDrivenDataUpdate) return;
    [self.tableView endUpdates];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
}

- (UIView *)viewWithIcon:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (Task *)taskAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fetchedResultsController.sections.count > indexPath.section) {
        id<NSFetchedResultsSectionInfo> sectionInfo =
            [self.fetchedResultsController sections][indexPath.section];
        if ([sectionInfo numberOfObjects] > indexPath.item) {
            return [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    return nil;
}

#pragma mark - Search
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [HRPGSearchDataManager sharedManager].searchString = searchText;

    if ([[HRPGSearchDataManager sharedManager].searchString isEqualToString:@""]) {
        [HRPGSearchDataManager sharedManager].searchString = nil;
    }

    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];

    [HRPGSearchDataManager sharedManager].searchString = nil;

    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    [searchBar resignFirstResponder];

    [self.tableView reloadData];
}

- (void)scrollToTaskWithId:(NSString *)taskID {
    NSInteger index = 0;
    NSIndexPath *indexPath;
    for (Task *task in self.fetchedResultsController.fetchedObjects) {
        if ([task.id isEqualToString:taskID]) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            break;
        }
        index++;
    }
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FormSegue"]) {
        HRPGNavigationController *destViewController = segue.destinationViewController;
        destViewController.sourceViewController = self;

        HRPGFormViewController *formController =
            (HRPGFormViewController *)destViewController.topViewController;
        formController.readableTaskType = self.readableName;
        HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;
        formController.activeTags = tabBarController.selectedTags;
        formController.taskType = self.typeName;
        if (editedTask) {
            formController.task = editedTask;
            formController.editTask = YES;
            editedTask = nil;
        }
    } else if ([segue.identifier isEqualToString:@"FilterSegue"]) {
        HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;
        HRPGNavigationController *navigationController = segue.destinationViewController;
        navigationController.sourceViewController = self;
        HRPGFilterViewController *filterController =
            (HRPGFilterViewController *)navigationController.topViewController;
        filterController.selectedTags = [tabBarController.selectedTags mutableCopy];
        filterController.taskType = self.typeName;
    }
}

- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (void) startAutoScrolling {
    if (self.scrollTimer == nil) {
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:(0.03)
                                                          target:self selector:@selector(autoscrollTimer) userInfo:nil repeats:YES];
    }
}

- (void) autoscrollTimer {
    if (self.autoScrollSpeed == 0) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    } else {
        CGPoint scrollPoint = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y+self.autoScrollSpeed);
        if (scrollPoint.y > -self.tableView.contentInset.top && scrollPoint.y < (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
            [self.tableView setContentOffset:scrollPoint animated:NO];
        }
    }
}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(11.0) {
    self.movedTask = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *taskName = self.movedTask.text;
    sourceIndexPath = indexPath;
    
    NSData *data = [taskName dataUsingEncoding:NSUTF16StringEncoding];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
    
    [itemProvider registerDataRepresentationForTypeIdentifier:[NSString stringWithString:kUTTypeUTF16PlainText] visibility:NSItemProviderRepresentationVisibilityOwnProcess loadHandler:^NSProgress * _Nullable(void (^ _Nonnull completionHandler)(NSData * _Nullable, NSError * _Nullable)) {
        completionHandler(data, nil);
        return nil;
    }];
    self.userDrivenDataUpdate = YES;
    return @[[[UIDragItem alloc] initWithItemProvider: itemProvider]];
}

- (BOOL)tableView:(UITableView *)tableView canHandleDropSession:(id<UIDropSession>)session NS_AVAILABLE_IOS(11.0) {
    return YES;
}

- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(11.0) {
    int taskOrder = 0;
    self.movedTask.order = [NSNumber numberWithInteger:destinationIndexPath.item];
    for (Task *task in self.fetchedResultsController.fetchedObjects) {
        if ([task.id isEqualToString:self.movedTask.id]) {
            break;
        }
        task.order = [NSNumber numberWithInteger:taskOrder];
        taskOrder++;
    }
    return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
}

- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator NS_AVAILABLE_IOS(11.0) {
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [[HRPGManager sharedManager] moveTask:self.movedTask toPosition:[NSNumber numberWithInteger:destinationIndexPath.item] onSuccess:^() {
        [self.tableView reloadRowsAtIndexPaths:@[destinationIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        self.userDrivenDataUpdate = NO;
    } onError:^() {
        self.userDrivenDataUpdate = NO;
    }];
}

@end
