//
//  HRPGDailyTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGDailyTableViewController.h"
#import "Task.h"
#import "HRPGManager.h"
#import "ChecklistItem.h"
#import "NSString+Emoji.h"
#import "UIColor+LighterDarker.h"
#import "HRPGCheckBoxView.h"
#import "HRPGDailyTableViewCell.h"

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
        return @{@"text": NSLocalizedString(@"Defeat your repeating Daily tasks to gain gold and experience. Danger! Dailies will hurt your avatar if you don't complete them in time.", nil)};
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (void)configureCell:(HRPGDailyTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];

    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        int currentOffset = (int) (indexPath.item - self.openedIndexPath.item - 1);
        ChecklistItem *item;
        if ([task.checklist count] > currentOffset) {
            item = task.checklist[currentOffset];
        }
        [cell configureForItem:item forTask:task];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                item.currentlyChecking = [NSNumber numberWithBool:YES];
                item.completed = [NSNumber numberWithBool:![item.completed boolValue]];
                [self.sharedManager updateTask:task onSuccess:^() {
                    item.currentlyChecking = [NSNumber numberWithBool:NO];
                    if ([self isIndexPathVisible:indexPath]) {
                        [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                    }
                    NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                    if ([self isIndexPathVisible:taskPath]) {
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath, taskPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }                      onError:^() {
                    item.currentlyChecking = [NSNumber numberWithBool:NO];
                }];
            }
            
        };
    } else {
        [cell configureForTask:task withOffset:self.dayStart];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                task.currentlyChecking = [NSNumber numberWithBool:YES];
                NSString *actionName = [task.completed boolValue] ? @"down" : @"up";
                [self.sharedManager upDownTask:task direction:actionName onSuccess:^(NSArray *valuesArray) {
                    task.currentlyChecking = [NSNumber numberWithBool:NO];
                }onError:^() {
                    task.currentlyChecking = [NSNumber numberWithBool:NO];
                }];
            }
        };
        
        UITapGestureRecognizer *btnTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandSelectedCell:)];
        btnTapRecognizer.numberOfTapsRequired = 1;
        [cell.checklistIndicator addGestureRecognizer:btnTapRecognizer];
        
        //TODO: if we find a way to filter due dailies in predicate remove this
        if ([task.type isEqualToString:@"daily"] && ((self.filterType == TaskDailyFilterTypeDue && ![task dueTodayWithOffset:self.dayStart]) || (self.filterType == TaskDailyFilterTypeGrey && [task dueTodayWithOffset:self.dayStart]))) {
            cell.contentView.hidden = YES;
        } else {
            cell.contentView.hidden = NO;
        }
    }
}

- (void) expandSelectedCell:(UITapGestureRecognizer*)gesture {
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    [self tableView:self.tableView expandTaskAtIndexPath:indexPath];
}


@end
