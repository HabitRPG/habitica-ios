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

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@property NIKFontAwesomeIconFactory *iconFactory;
@property NIKFontAwesomeIconFactory *checkIconFactory;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic sharedManager;
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
    // border radius
    [v.layer setCornerRadius:5.0f];
    return cell;
}

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    UILabel *checklistLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        Task *task = [self.fetchedResultsController objectAtIndexPath:self.openedIndexPath];
        int currentOffset = (int) (indexPath.item - self.openedIndexPath.item - 1);
        ChecklistItem *item = task.checklist[currentOffset];
        label.text = [item.text stringByReplacingEmojiCheatCodesWithUnicode];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        checklistLabel.hidden = YES;
        cell.backgroundColor = [UIColor lightGrayColor];
        UIImageView *checkMarkView = (UIImageView *) [cell viewWithTag:3];
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
                item.completed = [NSNumber numberWithBool:NO];
                [self addActivityCounter];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
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
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
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
        UIImageView *checkMarkView = (UIImageView *) [cell viewWithTag:3];
        if ([task.completed boolValue]) {
            self.checkIconFactory.colors = @[[UIColor darkGrayColor]];
            if (animate) {
                if (checkMarkView.hidden) {
                    CGRect oldFrame = checkMarkView.frame;
                    checkMarkView.frame = CGRectMake(-oldFrame.size.width, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.width);
                    checkMarkView.hidden = NO;
                    checkMarkView.image = [self.checkIconFactory createImageForIcon:NIKFontAwesomeIconCheck];
                    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
                        checkMarkView.frame = CGRectMake(8, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.width);
                    }completion:nil];
                }
            } else {
                checkMarkView.hidden = NO;
                checkMarkView.image = [self.checkIconFactory createImageForIcon:NIKFontAwesomeIconCheck];
            }
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor colorWithWhite:0.581 alpha:1.000];
            }];
        } else {
            if (animate) {
                if (!checkMarkView.hidden) {
                    CGRect oldFrame = checkMarkView.frame;
                    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.9f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
                        checkMarkView.frame = CGRectMake(-oldFrame.size.width, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.width);
                    }completion:^(BOOL completed) {
                        checkMarkView.image = nil;
                        checkMarkView.hidden = YES;
                    }];
                }
            } else {
                checkMarkView.image = nil;
                checkMarkView.hidden = YES;
            }
            if (![task dueToday]) {
                [UIView animateWithDuration:0.4 animations:^() {
                    label.textColor = [UIColor colorWithWhite:0.581 alpha:1.000];
                }];
            } else {
                [UIView animateWithDuration:0.4 animations:^() {
                    label.textColor = [self.sharedManager getColorForValue:task.value];
                }];
            }
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
                    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
                }];
            }
        } else {
            if (self.openedIndexPath != nil && self.openedIndexPath.item == indexPath.item) {
                label.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor grayColor];
                cell.separatorInset = UIEdgeInsetsZero;
            } else {
                cell.backgroundColor = [UIColor whiteColor];
                cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
            }
        }
    }
}

- (void)configureSwiping:(MCSwipeTableViewCell *)cell withTask:(Task *)task {
    if ([task.completed boolValue]) {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconSquareO]];
        UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
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
        [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
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
