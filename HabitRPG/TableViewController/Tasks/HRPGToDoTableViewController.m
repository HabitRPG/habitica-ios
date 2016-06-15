//
//  HRPGToDoTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGToDoTableViewController.h"
#import "ChecklistItem.h"
#import "HRPGCheckBoxView.h"
#import "HRPGToDoTableViewCell.h"

@interface HRPGToDoTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property NSDateFormatter *dateFormatter;
@end

@implementation HRPGToDoTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic openedIndexPath;
@dynamic indexOffset;

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
    [self.sharedManager fetchCompletedTasks:nil onError:nil];
}
- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"todos"]) {
        return @{
            @"text" : NSLocalizedString(@"Complete your To-Dos in real life, then check them off "
                                        @"for GOLD and EXPERIENCE so you can earn Rewards and "
                                        @"unlock new features!",
                                        nil)
        };
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (void)configureCell:(HRPGToDoTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];

    cell.dateFormatter = self.dateFormatter;
    __weak HRPGToDoTableViewController *weakSelf = self;
    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item &&
        indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        int currentOffset = (int)(indexPath.item - self.openedIndexPath.item - 1);

        ChecklistItem *item;
        if ([task.checklist count] > currentOffset) {
            item = task.checklist[currentOffset];
        }
        [cell configureForItem:item forTask:task];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                item.currentlyChecking = @YES;
                item.completed = @(![item.completed boolValue]);
                [weakSelf.sharedManager updateTask:task
                    onSuccess:^() {
                        item.currentlyChecking = @NO;
                        if ([weakSelf isIndexPathVisible:indexPath]) {
                            [weakSelf configureCell:cell atIndexPath:indexPath withAnimation:YES];
                        }
                        NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                        if ([weakSelf isIndexPathVisible:taskPath]) {
                            NSArray *paths;
                            if (indexPath.item != taskPath.item) {
                                paths = @[ indexPath, taskPath ];
                            } else {
                                paths = @[ indexPath ];
                            }
                            [weakSelf.tableView
                                reloadRowsAtIndexPaths:paths
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    }
                    onError:^() {
                        item.currentlyChecking = @NO;
                    }];
            }
        };
    } else {
        [cell configureForTask:task];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                task.currentlyChecking = @YES;
                NSString *actionName = [task.completed boolValue] ? @"down" : @"up";
                [weakSelf.sharedManager upDownTask:task
                    direction:actionName
                    onSuccess:^(NSArray *valuesArray) {
                        task.currentlyChecking = @NO;
                    }
                    onError:^() {
                        task.currentlyChecking = @NO;
                    }];
            }
        };

        UITapGestureRecognizer *btnTapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(expandSelectedCell:)];
        btnTapRecognizer.numberOfTapsRequired = 1;
        [cell.checklistIndicator addGestureRecognizer:btnTapRecognizer];
    }
}

- (void)clearCompletedTasks:(UITapGestureRecognizer *)tapRecognizer {
    __weak HRPGToDoTableViewController *weakSelf = self;
    [self.sharedManager clearCompletedTasks:^() {
        [weakSelf.sharedManager fetchUser:nil onError:nil];
    } onError:nil];
}

- (void)expandSelectedCell:(UITapGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    [self tableView:self.tableView expandTaskAtIndexPath:indexPath];
}

- (void)didChangeFilter:(NSNotification *)notification {
    [super didChangeFilter:notification];
    if (self.filterType == TaskToDoFilterTypeDone) {
        if ([self.fetchedResultsController fetchedObjects].count == 0) {
            [self.sharedManager fetchCompletedTasks:nil onError:nil];
        }
    }
}

@end
