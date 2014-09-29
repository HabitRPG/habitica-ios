//
//  HRPGHabitTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitTableViewController.h"
#import "Task.h"
#import "HRPGManager.h"
#import "MCSwipeTableViewCell.h"
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import "NSString+Emoji.h"
#import "HRPGActivityIndicatorOverlayView.h"

@interface HRPGHabitTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NIKFontAwesomeIconFactory *iconFactory;
@end

@implementation HRPGHabitTableViewController

@dynamic readableName;
@dynamic typeName;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"Habit", nil);
    self.typeName = @"habit";
    [super viewDidLoad];
    self.iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.iconFactory.square = YES;
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UILabel *lastActionLabel = (UILabel*)[cell viewWithTag:4];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
    if (lastActionLabel.text.length == 0) {
        lastActionLabel.alpha = 0;
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
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIColor *color = [task taskColor];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    label.textColor = color;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    if (self.swipeDirection) {
        if ([task.down boolValue]) {
            [cell viewWithTag:3].backgroundColor = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
            [cell viewWithTag:3].hidden = NO;
        } else {
            [cell viewWithTag:3].hidden = YES;
        }
        
        if ([task.up boolValue]) {
            [cell viewWithTag:2].backgroundColor = [UIColor colorWithRed:0.292 green:0.642 blue:0.013 alpha:1.000];
            [cell viewWithTag:2].hidden = NO;
        } else {
            [cell viewWithTag:2].hidden = YES;
        }
    } else {
        if ([task.up boolValue]) {
            [cell viewWithTag:3].backgroundColor = [UIColor colorWithRed:0.292 green:0.642 blue:0.013 alpha:1.000];
            [cell viewWithTag:3].hidden = NO;
        } else {
            [cell viewWithTag:3].hidden = YES;
        }
        
        if ([task.down boolValue]) {
            [cell viewWithTag:2].backgroundColor = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
            [cell viewWithTag:2].hidden = NO;
        } else {
            [cell viewWithTag:2].hidden = YES;
        }
    }
    
    
    [self configureSwiping:cell withTask:task];
}

- (void)configureSwiping:(MCSwipeTableViewCell *)cell withTask:(Task *)task {
    if (self.tableView.editing) {
        cell.view3 = nil;
    }
    if ([task.up boolValue]) {
        MCSwipeTableViewCellState state;
        if (self.swipeDirection) {
            state = MCSwipeTableViewCellState1;
        } else {
            state = MCSwipeTableViewCellState3;
        }
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconPlus]];
        UIColor *greenColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
        [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:state completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self addActivityCounter];
            [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(NSArray *valuesArray){
                [self removeActivityCounter];
                [self displayTaskResponse:valuesArray];
            }                      onError:^(){
                [self removeActivityCounter];
            }];
        }];
    }
    if ([task.down boolValue]) {
        MCSwipeTableViewCellState state;
        if (self.swipeDirection) {
            state = MCSwipeTableViewCellState3;
        } else {
            state = MCSwipeTableViewCellState1;
        }
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconMinus]];
        UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:state completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self addActivityCounter];
            [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(NSArray *valuesArray){
                [self removeActivityCounter];
                [self displayTaskResponse:valuesArray];
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
