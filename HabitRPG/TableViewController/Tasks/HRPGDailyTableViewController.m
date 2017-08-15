//
//  HRPGDailyTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGDailyTableViewController.h"
#import "ChecklistItem.h"
#import "HRPGCheckBoxView.h"
#import "Habitica-Swift.h"

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic openedIndexPath;
@dynamic indexOffset;

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

    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item &&
        indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        int currentOffset = (int)(indexPath.item - self.openedIndexPath.item - 1);
        ChecklistItem *item;
        if ([task.checklist count] > currentOffset) {
            item = task.checklist[currentOffset];
        }
        [cell configureWithChecklistItem:item task:task];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                item.currentlyChecking = @YES;
                item.completed = @(![item.completed boolValue]);
                [self.sharedManager scoreChecklistItem:task
                                         checklistItem:item
                                             onSuccess:^() {
                                                 item.currentlyChecking = @NO;
                                                 if ([self isIndexPathVisible:indexPath]) {
                                                     [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                                                 }
                                                 NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                                                 if ([self isIndexPathVisible:taskPath]) {
                                                     NSArray *paths;
                                                     if (indexPath.item != taskPath.item) {
                                                         paths = @[ indexPath, taskPath ];
                                                     } else {
                                                         paths = @[ indexPath ];
                                                     }
                                                     [self.tableView
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
        [cell configureWithTask:task offset:self.dayStart];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                task.currentlyChecking = @YES;
                NSString *actionName = [task.completed boolValue] ? @"down" : @"up";
                [self.sharedManager upDownTask:task
                    direction:actionName
                    onSuccess:^() {
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

        // TODO: if we find a way to filter due dailies in predicate remove this
        if ([task.type isEqualToString:@"daily"] &&
            ((self.filterType == TaskDailyFilterTypeDue &&
              ![task dueTodayWithOffset:self.dayStart]) ||
             (self.filterType == TaskDailyFilterTypeGrey &&
              [task dueTodayWithOffset:self.dayStart] && ![task.completed boolValue]))) {
            cell.contentView.hidden = YES;
        } else {
            cell.contentView.hidden = NO;
        }
    }
}

- (void)expandSelectedCell:(UITapGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    [self tableView:self.tableView expandTaskAtIndexPath:indexPath];
}

@end
