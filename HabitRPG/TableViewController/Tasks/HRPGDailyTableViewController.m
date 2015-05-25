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
#import "MCSwipeTableViewCell.h"
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import "NSString+Emoji.h"
#import "UIColor+LighterDarker.h"
#import "HRPGCheckBoxView.h"

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NIKFontAwesomeIconFactory *iconFactory;
@property NIKFontAwesomeIconFactory *checkIconFactory;
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
    self.iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.iconFactory.square = YES;
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;

    self.checkIconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.checkIconFactory.square = YES;
    self.checkIconFactory.colors = @[[UIColor darkGrayColor]];
    self.checkIconFactory.strokeColor = [UIColor darkGrayColor];
    self.checkIconFactory.size = 17.0f;
    self.checkIconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    UILabel *v = (UILabel *) [cell viewWithTag:2];
    [v.layer setCornerRadius:5.0f];
    return cell;
}

- (void) displayTaskDetailAtIndexPath:(NSIndexPath*)indexPath adjustValue:(int) adjustment {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *lastActionLabel = (UILabel*)[cell viewWithTag:4];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
    if (!(self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item + self.indexOffset))) {
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (lastActionLabel.text.length == 0) {
            lastActionLabel.alpha = 0;
            int value = [task.streak intValue] + adjustment;
            lastActionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Streak: %d", nil), value];
            [UIView animateWithDuration:0.3 animations:^() {
                [lastActionLabel layoutIfNeeded];
                [titleLabel layoutIfNeeded];
                lastActionLabel.alpha = 1;
            } completion:^(BOOL completed) {
                if (completed) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        lastActionLabel.text = nil;
                        [UIView animateWithDuration:0.3 animations:^() {
                            [lastActionLabel layoutIfNeeded];
                            [titleLabel layoutIfNeeded];
                            lastActionLabel.alpha = 0;
                        }completion:nil];
                    });
                }
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self displayTaskDetailAtIndexPath:indexPath adjustValue:0];
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    UILabel *checklistLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    HRPGCheckBoxView *checkBox = (HRPGCheckBoxView *) [cell viewWithTag:3];
    if (checkBox == nil) {
        checkBox = [[HRPGCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 40, cell.frame.size.height)];
        checkBox.tag = 3;
        [cell.contentView addSubview:checkBox];
    } else {
        checkBox.frame = CGRectMake(0, 0, 50, cell.frame.size.height);
    }
    Task *task = [self taskAtIndexPath:indexPath];

    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        int currentOffset = (int) (indexPath.item - self.openedIndexPath.item - 1);
        
        ChecklistItem *item;
        if ([task.checklist count] > currentOffset) {
            item = task.checklist[currentOffset];
        }
        label.text = [item.text stringByReplacingEmojiCheatCodesWithUnicode];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        checklistLabel.hidden = YES;
        cell.backgroundColor = [UIColor lightGrayColor];
        checkBox.boxColor = [UIColor darkGrayColor];
        checkBox.checkColor = [UIColor lightGrayColor];
        if ([item.completed boolValue]) {
            self.checkIconFactory.colors = @[[UIColor whiteColor]];
            label.textColor = [UIColor whiteColor];
            checkBox.wasTouched = ^() {
                item.completed = [NSNumber numberWithBool:NO];
                [self addActivityCounter];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                    [self removeActivityCounter];
                }                      onError:^() {
                    [self removeActivityCounter];
                }];
            };
            [checkBox setChecked:YES animated:YES];
        } else {
            label.textColor = [UIColor whiteColor];
            checkBox.wasTouched = ^() {
                item.completed = [NSNumber numberWithBool:YES];
                [self addActivityCounter];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                    [self removeActivityCounter];
                }                      onError:^() {
                    [self removeActivityCounter];
                }];

            };
            [checkBox setChecked:NO animated:YES];
        }

    } else {
        UILabel *streakLabel = (UILabel *) [cell viewWithTag:4];
        label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSNumber *checklistCount = [task valueForKeyPath:@"checklist.@count"];
        if ([checklistCount integerValue] > 0) {
            int checkedCount = 0;
            for (ChecklistItem *item in [task checklist]) {
                if ([item.completed boolValue]) {
                    checkedCount++;
                }
            }
            checklistLabel.text = [NSString stringWithFormat:@"%d/%@", checkedCount, checklistCount];
            if (checkedCount == [checklistCount integerValue]) {
                checklistLabel.backgroundColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
            } else {
                checklistLabel.backgroundColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
            }
            checklistLabel.hidden = NO;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandSelectedCell:)];
            tapRecognizer.numberOfTapsRequired = 1;
            [checklistLabel addGestureRecognizer:tapRecognizer];
        } else {
            checklistLabel.hidden = YES;
        }
        
        if ([task.completed boolValue]) {
            checkBox.boxColor = [UIColor colorWithWhite:0.705 alpha:1.000];
            checkBox.checkColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            self.checkIconFactory.colors = @[[UIColor darkGrayColor]];
            label.textColor = [UIColor darkGrayColor];
            cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            [checkBox setChecked:YES animated:YES];
            streakLabel.textColor = [UIColor darkGrayColor];
            checkBox.wasTouched = ^() {
                [self addActivityCounter];
                [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(NSArray *valuesArray) {
                    [self removeActivityCounter];
                }onError:^() {
                    [self removeActivityCounter];
                }];
            };
        } else {
            checkBox.wasTouched = ^() {
                [self addActivityCounter];
                [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(NSArray *valuesArray) {
                    [self removeActivityCounter];
                }onError:^() {
                    [self removeActivityCounter];
                }];
            };
            [checkBox setChecked:NO animated:YES];
            if (![task dueToday]) {
                checkBox.boxColor = [UIColor lightGrayColor];
                label.textColor = [UIColor darkGrayColor];
                cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.000];
                streakLabel.textColor = [UIColor darkGrayColor];
            } else {
                checkBox.boxColor = [[task taskColor] darkerColor];
                cell.backgroundColor = [task lightTaskColor];
                label.textColor = [UIColor blackColor];
                streakLabel.textColor = [UIColor blackColor];
            }
        }
    }
}

- (void) expandSelectedCell:(UITapGestureRecognizer*)gesture {
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    [self tableView:self.tableView expandTaskAtIndexPath:indexPath];
}


@end
