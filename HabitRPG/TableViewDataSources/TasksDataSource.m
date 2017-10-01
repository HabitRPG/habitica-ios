//
//  TasksDataSource.m
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "TasksDataSource.h"
#import "Habitica-Swift.h"
#import "HRPGManager.h"

@interface TasksDataSource ()
@property NSIndexPath *expandedIndexPath;
@end

@implementation TasksDataSource

- (void)configureCell:(ToDoTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    HRPGTask *task = self.tasks[indexPath.row];
    cell.isExpanded = self.expandedIndexPath != nil && indexPath.item == self.expandedIndexPath.item;
    
    UITapGestureRecognizer *btnTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(expandSelectedCell:)];
    btnTapRecognizer.numberOfTapsRequired = 1;
    [cell.checklistIndicator addGestureRecognizer:btnTapRecognizer];
    
    __weak ToDoTableViewCell *weakCell = cell;
    cell.checklistItemTouched = ^(ChecklistItem *item) {
        if (![item.currentlyChecking boolValue]) {
            item.currentlyChecking = @YES;
            item.completed = @(![item.completed boolValue]);
//            [[HRPGManager sharedManager] scoreChecklistItem:task
//                                              checklistItem:item
//                                                  onSuccess:^() {
//                                                      item.currentlyChecking = @NO;
//                                                      if ([self isIndexPathVisible:indexPath]) {
//                                                          [self configureCell:weakCell atIndexPath:indexPath withAnimation:YES];
//                                                      }
//                                                  } onError:^() {
//                                                      item.currentlyChecking = @NO;
//                                                  }];
        }
    };
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    cell.taskDetailLine.dateFormatter = dateFormatter;
    
    [cell configureNewWithTask:task];
    cell.checkBox.wasTouched = ^() {
//        if (![task.currentlyChecking boolValue]) {
//            task.currentlyChecking = @YES;
//            NSString *actionName = [task.completed boolValue] ? @"down" : @"up";
//            [[HRPGManager sharedManager] upDownTask:task
//                                          direction:actionName
//                                          onSuccess:^() {
//                                              task.currentlyChecking = @NO;
//                                          }
//                                            onError:^() {
//                                                task.currentlyChecking = @NO;
//                                            }];
//        }
    };
}

- (void)expandSelectedCell:(UITapGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    NSIndexPath *expandedPath = self.expandedIndexPath;
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

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath {
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.item == indexPath.item && index.section == indexPath.section) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
//        HRPGTask *task = self.tasks[indexPath.row];
//        [[HRPGManager sharedManager] deleteTask:task
//                                      onSuccess:nil onError:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
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

@end
