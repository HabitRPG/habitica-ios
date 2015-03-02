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
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIColor *color = [task lightTaskColor];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    cell.backgroundColor = color;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UISegmentedControl *upDownControl = (UISegmentedControl *)[cell viewWithTag:2];
    [upDownControl addTarget:self
                             action:@selector(segmentedControlUpdated:)
                   forControlEvents:UIControlEventValueChanged];
    upDownControl.tintColor = [task taskColor];
    [upDownControl removeAllSegments];
    if ([task.up boolValue]) {
        [upDownControl insertSegmentWithImage:[self.iconFactory createImageForIcon:NIKFontAwesomeIconPlus] atIndex:0 animated:NO];
    }
    if ([task.down boolValue]) {
        [upDownControl insertSegmentWithImage:[self.iconFactory createImageForIcon:NIKFontAwesomeIconMinus] atIndex:[upDownControl numberOfSegments] animated:NO];
    }
}

- (void)segmentedControlUpdated:(UISegmentedControl *)segmentedControl {
    CGPoint senderOriginInTableView = [segmentedControl convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderOriginInTableView];
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *upDown;
    if (segmentedControl.selectedSegmentIndex == 0 && segmentedControl.numberOfSegments == 2) {
        upDown = @"up";
    } else {
        upDown = @"down";
    }
    [self addActivityCounter];
    [self.sharedManager upDownTask:task direction:upDown onSuccess:^(NSArray *valuesArray){
        [self removeActivityCounter];
        [self displayTaskResponse:valuesArray];
    }                      onError:^(){
        [self removeActivityCounter];
    }];
}

@end
