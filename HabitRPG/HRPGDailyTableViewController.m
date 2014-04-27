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
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic sharedManager;
@dynamic openedIndexPath;
@dynamic indexOffset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.iconFactory.square = YES;
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
    self.readableName = NSLocalizedString(@"Daily", nil);
    self.typeName = @"daily";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *v = (UILabel*)[cell viewWithTag:2];
    // border radius
    [v.layer setCornerRadius:5.0f];
    return cell;
}

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate
{
    UILabel *checklistLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item+self.indexOffset)) {
        Task *task = [self.fetchedResultsController objectAtIndexPath:self.openedIndexPath];
        int currentOffset = (int)(indexPath.item - self.openedIndexPath.item-1);
        ChecklistItem *item = task.checklist[currentOffset];
        label.text = [item.text stringByReplacingEmojiCheatCodesWithUnicode];
        checklistLabel.hidden = YES;
        cell.backgroundColor = [UIColor lightGrayColor];
        if ([item.completed boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor darkTextColor];
            }];
            UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconSquareO]];
            UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
            [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                item.completed = [NSNumber numberWithBool:NO];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                }onError:^() {
                    
                }];
            }];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor whiteColor];
            }];
            UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconCheckSquareO]];
            UIColor *greenColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
            [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                item.completed = [NSNumber numberWithBool:YES];
                [self.sharedManager updateTask:task onSuccess:^() {
                    
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                }onError:^() {
                    
                }];
            }];
        }

    } else {
        if (self.openedIndexPath.item+self.indexOffset < indexPath.item && self.indexOffset > 0) {
            indexPath = [NSIndexPath indexPathForItem:indexPath.item - self.indexOffset inSection:indexPath.section];
        }
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
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
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor colorWithWhite:0.581 alpha:1.000];
            }];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
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
        
        if (self.openedIndexPath != nil && self.openedIndexPath.item == indexPath.item) {
            [UIView animateWithDuration:0.4 animations:^() {
                label.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor grayColor];
            }];
        } else {
            [UIView animateWithDuration:0.4 animations:^() {
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }
    }
}

-(void)configureSwiping:(MCSwipeTableViewCell *)cell withTask:(Task *)task {
    if ([task.completed boolValue]) {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconSquareO]];
        UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(){
                
            }onError:^(){
                
            }];
        }];
    } else {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconCheckSquareO]];
        UIColor *greenColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
        [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(){
                
            }onError:^(){
                
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
