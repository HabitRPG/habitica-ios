//
//  HRPGDailyTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGDailyTableViewController.h"
#import "ChecklistItem.h"
#import "HRPGCheckBoxView.h"
#import "Habitica-Swift.h"

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *expandedIndexPath;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"Daily", nil);
    self.typeName = @"daily";
    [super viewDidLoad];

    self.tutorialIdentifier = @"dailies";
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"dailies"]) {
        return @{
            @"textList" : @[NSLocalizedString(@"Make Dailies for time-sensitive tasks that need to be done on a regular schedule.", nil),
                            NSLocalizedString(@"Be careful — if you miss one, your avatar will take damage overnight. Checking them off consistently brings great rewards!", nil)]
        };
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (NSString *)getCellNibName {
    return @"DailyTableViewCell";
}

- (void)configureCell:(DailyTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];
    cell.isExpanded = self.expandedIndexPath != nil && indexPath.item == self.expandedIndexPath.item;
    [cell configureWithTask:task offset:self.dayStart];
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
    
    __weak DailyTableViewCell *weakCell = cell;
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
    
    cell.checklistIndicatorTouched = ^() {
        [self expandSelectedCell:indexPath];
    };
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
