//
//  HRPGToDoTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGToDoTableViewController.h"
#import "Task.h"
#import "HRPGManager.h"
#import "ChecklistItem.h"
#import "MCSwipeTableViewCell.h"
#import "HRPGSwipeTableViewCell.h"
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import "NSString+Emoji.h"
#import <NSDate+TimeAgo.h>

@interface HRPGToDoTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@property NIKFontAwesomeIconFactory *iconFactory;
@property NIKFontAwesomeIconFactory *checkIconFactory;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property NSDateFormatter *dateFormatter;

@end

@implementation HRPGToDoTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic sharedManager;
@dynamic openedIndexPath;
@dynamic indexOffset;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"To-Do", nil);
    self.typeName = @"todo";
    [super viewDidLoad];
    self.iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.iconFactory.square = YES;
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;

    self.checkIconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.checkIconFactory.square = YES;
    self.checkIconFactory.colors = @[[UIColor grayColor]];
    self.checkIconFactory.strokeColor = [UIColor grayColor];
    self.checkIconFactory.size = 17.0f;
    self.checkIconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    UILabel *v = (UILabel *) [cell viewWithTag:2];
    // border radius
    [v.layer setCornerRadius:5.0f];
    return cell;
}

- (void)configureCell:(HRPGSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    UILabel *checklistLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    UIImageView *checkMarkView = (UIImageView *) [cell viewWithTag:3];
    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        Task *task = [self.fetchedResultsController objectAtIndexPath:self.openedIndexPath];
        int currentOffset = (int) (indexPath.item - self.openedIndexPath.item - 1);
        ChecklistItem *item = task.checklist[currentOffset];
        label.text = [item.text stringByReplacingEmojiCheatCodesWithUnicode];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        checklistLabel.hidden = YES;
        cell.backgroundColor = [UIColor lightGrayColor];
        if ([item.completed boolValue]) {
            self.checkIconFactory.colors = @[[UIColor whiteColor]];
            checkMarkView.image = [self.checkIconFactory createImageForIcon:NIKFontAwesomeIconCheck];
            checkMarkView.hidden = NO;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor darkTextColor];
            }];
            UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconSquareO]];
            UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
            [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                item.completed = [NSNumber numberWithBool:NO];;
                [self addActivityCounter];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:(HRPGSwipeTableViewCell *) cell atIndexPath:indexPath withAnimation:YES];
                    [self removeActivityCounter];
                }                      onError:^() {
                    [self removeActivityCounter];
                }];
            }];
        } else {
            checkMarkView.image = nil;
            checkMarkView.hidden = YES;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor whiteColor];
            }];
            UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconCheckSquareO]];
            UIColor *greenColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
            [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                item.completed = [NSNumber numberWithBool:YES];
                [self addActivityCounter];
                [self.sharedManager updateTask:task onSuccess:^() {

                    [self configureCell:(HRPGSwipeTableViewCell *) cell atIndexPath:indexPath withAnimation:YES];
                    [self removeActivityCounter];
                }                      onError:^() {
                    [self removeActivityCounter];
                }];
            }];
        }

    } else {
        if (self.openedIndexPath.item + self.indexOffset < indexPath.item && self.indexOffset > 0) {
            indexPath = [NSIndexPath indexPathForItem:indexPath.item - self.indexOffset inSection:indexPath.section];
        }
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        if (task.duedate) {
            UILabel *subLabel = (UILabel *) [cell viewWithTag:4];
            subLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            if ([task.duedate compare:[NSDate date]] == NSOrderedAscending) {
                subLabel.textColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
                subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due %@", nil), [task.duedate timeAgo]];
            } else {
                [UIColor colorWithWhite:0.581 alpha:1.000];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *differenceValue = [calendar components:NSDayCalendarUnit
                                                                fromDate:[NSDate date] toDate:task.duedate options:0];
                if ([differenceValue day] < 7) {
                    if ([differenceValue day] == 1) {
                        subLabel.text = NSLocalizedString(@"Due in 1 day", nil);
                    } else {
                        subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due in %d days", nil), [differenceValue day]];
                    }
                } else {
                    subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due until %@", nil), [self.dateFormatter stringFromDate:task.duedate]];
                }
            }
        }
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
        } else {
            checklistLabel.hidden = YES;
        }
        if ([task.completed boolValue]) {
            self.checkIconFactory.colors = @[[UIColor grayColor]];
            checkMarkView.image = [self.checkIconFactory createImageForIcon:NIKFontAwesomeIconCheck];
            checkMarkView.hidden = NO;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor colorWithWhite:0.581 alpha:1.000];
            }];
        } else {
            checkMarkView.image = nil;
            checkMarkView.hidden = YES;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [self.sharedManager getColorForValue:task.value];
            }];
        }

        [self configureSwiping:cell withTask:task];
        if (animate) {
            if (self.openedIndexPath != nil && self.openedIndexPath.item == indexPath.item) {
                self.checkIconFactory.colors = @[[UIColor whiteColor]];
                checkMarkView.image = [self.checkIconFactory createImageForIcon:NIKFontAwesomeIconCheck];
                [UIView animateWithDuration:0.4 animations:^() {
                    label.textColor = [UIColor whiteColor];
                    cell.backgroundColor = [UIColor grayColor];
                    cell.separatorInset = UIEdgeInsetsZero;
                }];
            } else {
                self.checkIconFactory.colors = @[[UIColor grayColor]];
                checkMarkView.image = [self.checkIconFactory createImageForIcon:NIKFontAwesomeIconCheck];
                [UIView animateWithDuration:0.4 animations:^() {
                    cell.backgroundColor = [UIColor whiteColor];
                    cell.separatorInset = UIEdgeInsetsMake(0, 42, 0, 0);

                }];
            }
        } else {
            if (self.openedIndexPath != nil && self.openedIndexPath.item == indexPath.item) {
                label.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor grayColor];
                cell.separatorInset = UIEdgeInsetsZero;
            } else {
                cell.backgroundColor = [UIColor whiteColor];
                cell.separatorInset = UIEdgeInsetsMake(0, 42, 0, 0);

            }
        }
    }
}

- (void)configureSwiping:(HRPGSwipeTableViewCell *)cell withTask:(Task *)task {
    if ([task.completed boolValue]) {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconSquareO]];
        UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self addActivityCounter];
            task.completed = [NSNumber numberWithBool:NO];
            [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(){
                [self removeActivityCounter];
            }                      onError:^(){
                [self removeActivityCounter];
            }];
        }];
    } else {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconCheckSquareO]];
        UIColor *greenColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
        [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self addActivityCounter];
            task.completed = [NSNumber numberWithBool:YES];
            [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(){
                [self removeActivityCounter];
            }                      onError:^(){
                [self removeActivityCounter];
            }];
        }];
    }
}

- (UIView *)viewWithIcon:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
