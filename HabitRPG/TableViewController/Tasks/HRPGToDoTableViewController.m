//
//  HRPGToDoTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGToDoTableViewController.h"
#import "ChecklistItem.h"
#import "HRPGCheckBoxView.h"
#import "Habitica-Swift.h"

@interface HRPGToDoTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSDateFormatter *dateFormatter;
@property NSIndexPath *expandedIndexPath;
@end

@implementation HRPGToDoTableViewController

@dynamic readableName;
@dynamic typeName;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"To-Do", nil);
    self.typeName = @"todo";
    [super viewDidLoad];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;

    self.tutorialIdentifier = @"todos";
}

- (void)refresh {
    [super refresh];
    [[HRPGManager sharedManager] fetchCompletedTasks:nil onError:nil];
}
- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"todos"]) {
        return @{
            @"textList" : @[NSLocalizedString(@"Use To-Dos to keep track of tasks you need to do just once.", nil),
                            NSLocalizedString(@"If your To-Do has to be done by a certain time, set a due date. Looks like you can check one off — go ahead!", nil)]
                            
        };
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (NSString *)getCellNibName {
    return @"ToDoTableViewCell";
}

- (void)configureCell:(ToDoTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];
    cell.isExpanded = self.expandedIndexPath != nil && indexPath.item == self.expandedIndexPath.item;
    
    cell.checklistIndicatorTouched = ^() {
        [self expandSelectedCell:indexPath];
    };
    
    __weak ToDoTableViewCell *weakCell = cell;
    cell.checklistItemTouched = ^(ChecklistItem *item) {
        if (![item.currentlyChecking boolValue]) {
            item.currentlyChecking = @YES;
            item.completed = @(![item.completed boolValue]);
            [[HRPGManager sharedManager] scoreChecklistItem:task
                                              checklistItem:item
                                                  onSuccess:^() {
                                                      item.currentlyChecking = @NO;
                                                      if ([self isIndexPathVisible:indexPath]) {
                                                          [self configureCell:weakCell atIndexPath:indexPath withAnimation:YES];
                                                      }
                                                  } onError:^() {
                                                      item.currentlyChecking = @NO;
                                                  }];
        }
    };
    
    cell.taskDetailLine.dateFormatter = self.dateFormatter;
    [cell configureWithTask:task];
    cell.checkboxTouched = ^() {
        if (![task.currentlyChecking boolValue]) {
            task.currentlyChecking = @YES;
            NSString *actionName = [task.completed boolValue] ? @"down" : @"up";
            [[HRPGManager sharedManager] upDownTask:task
                                          direction:actionName
                                          onSuccess:^() {
                                              task.currentlyChecking = @NO;
                                          }
                                            onError:^() {
                                                task.currentlyChecking = @NO;
                                            }];
        }
    };
}

- (void)clearCompletedTasks:(UITapGestureRecognizer *)tapRecognizer {
    [[HRPGManager sharedManager] clearCompletedTasks:^() {
        [[HRPGManager sharedManager] fetchUser:nil onError:nil];
    } onError:nil];
}

- (void)didChangeFilter:(NSNotification *)notification {
    [super didChangeFilter:notification];
    if (self.filterType == TaskToDoFilterTypeDone) {
        if ([self.fetchedResultsController fetchedObjects].count == 0) {
            [[HRPGManager sharedManager] fetchCompletedTasks:nil onError:nil];
        }
    }
}

- (void)expandSelectedCell:(NSIndexPath *)indexPath {
    NSIndexPath *expandedPath = self.expandedIndexPath;
    if ([self.tableView numberOfRowsInSection:0] < expandedPath.item) {
        expandedPath = nil;
    }
    self.expandedIndexPath = indexPath;
    if (expandedPath == nil || indexPath.item == expandedPath.item) {
        CheckedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.isExpanded = !cell.isExpanded;
        if (!cell.isExpanded) {
            self.expandedIndexPath = nil;
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    } else {
        CheckedTableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:expandedPath];
        CheckedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView beginUpdates];
        cell.isExpanded = YES;
        oldCell.isExpanded = NO;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath, expandedPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

@end
