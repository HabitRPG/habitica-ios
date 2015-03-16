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
#import "UIColor+LighterDarker.h"

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
    self.iconFactory = [NIKFontAwesomeIconFactory buttonIconFactory];
    self.iconFactory.padded = NO;
    self.iconFactory.size = 12;
    self.iconFactory.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAutomatic;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

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
    [cell setSeparatorInset:UIEdgeInsetsZero];
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIColor *color = [task lightTaskColor];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    cell.backgroundColor = color;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIButton *upButton = (UIButton *)[cell viewWithTag:2];
    UIButton *downButton = (UIButton *)[cell viewWithTag:3];
    UIView *seperatorView = [cell viewWithTag:5];
    
    [upButton setTitleColor:[[task taskColor] darkerColor] forState:UIControlStateHighlighted];
    [downButton setTitleColor:[[task taskColor] darkerColor] forState:UIControlStateHighlighted];
    [upButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [downButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLayoutConstraint *upConstraint;
    NSLayoutConstraint *downConstraint;
    NSLayoutConstraint *seperatorConstraint;
    for (NSLayoutConstraint *con in upButton.constraints) {
        if (con.firstItem == upButton || con.secondItem == upButton) {
            upConstraint = con;
            break;
        }
    }
    for (NSLayoutConstraint *con in downButton.constraints) {
        if (con.firstItem == downButton || con.secondItem == downButton) {
            downConstraint = con;
            break;
        }
    }

    for (NSLayoutConstraint *con in seperatorView.constraints) {
        if (con.firstItem == seperatorView || con.secondItem == seperatorView) {
            seperatorConstraint = con;
            break;
        }
    }
    if ([task.up boolValue]) {
        upButton.hidden = NO;
        upButton.backgroundColor = [task taskColor];
        if (![task.down boolValue]) {
            upConstraint.constant = 101;
        } else {
            upConstraint.constant = 50;
        }
    } else {
        upButton.hidden = YES;
        upConstraint.constant = 0;
    }
    if ([task.down boolValue]) {
        downButton.hidden = NO;
        downButton.backgroundColor = [task taskColor];
        if (![task.up boolValue]) {
            downConstraint.constant = 101;
        } else {
            downConstraint.constant = 50;
        }
    } else {
        downButton.hidden = YES;
        downConstraint.constant = 0;
    }
    
    if ([task.up boolValue] && [task.down boolValue]) {
        seperatorView.hidden = NO;
        seperatorView.backgroundColor = [[task taskColor] darkerColor];
        seperatorConstraint.constant = 1;
    } else {
        seperatorView.hidden = YES;
        seperatorConstraint.constant = 0;
    }
}

- (void)buttonPressed:(UIButton *)button {
    CGPoint senderOriginInTableView = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderOriginInTableView];
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *upDown;
    if ([button.titleLabel.text isEqualToString:@"+"]) {
        upDown = @"up";
    } else {
        upDown = @"down";
    }
    [self addActivityCounter];
    [self.sharedManager upDownTask:task direction:upDown onSuccess:^(NSArray *valuesArray){
        [self removeActivityCounter];
    }                      onError:^(){
        [self removeActivityCounter];
    }];
}

@end
