//
//  HRPGCoachmarkFrameProvider.m
//  Habitica
//
//  Created by Elliot Schrock on 6/29/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import "HRPGCoachmarkFrameProvider.h"

@implementation HRPGCoachmarkFrameProvider

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"addTask"]) {
        return @{ @"text" : NSLocalizedString(@"Tap to add a new task.", nil) };
    } else if ([tutorialIdentifier isEqualToString:@"editTask"]) {
        return @{
                 @"text" : NSLocalizedString(
                                             @"Tap a task to edit it and add reminders. Swipe left to delete it.", nil)
                 };
    } else if ([tutorialIdentifier isEqualToString:@"filterTask"]) {
        return @{ @"text" : NSLocalizedString(@"Tap to filter tasks.", nil) };
    } else if ([tutorialIdentifier isEqualToString:@"reorderTask"]) {
        return @{@"text" : NSLocalizedString(@"Hold down on a task to drag it around.", nil)};
    }
    return nil;
}

- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier {
    if ([coachMarkIdentifier isEqualToString:@"addTask"]) {
        return CGRectMake(self.view.frame.size.width - 47, 19, 44, 44);
    } else if ([coachMarkIdentifier isEqualToString:@"editTask"]) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
            
            UITableViewCell *cell;
            for (NSIndexPath *indexPath in visibleCells) {
                cell = [self.tableView cellForRowAtIndexPath:indexPath];
                CGRect frame = [self.tableView
                                convertRect:cell.frame
                                toView:self.parentViewController.parentViewController.view];
                if (frame.origin.y >= self.tableView.contentInset.top) {
                    return frame;
                }
            }
            return [self.tableView convertRect:cell.frame
                                        toView:self.parentViewController.parentViewController.view];
        }
    } else if ([coachMarkIdentifier isEqualToString:@"filterTask"]) {
        NSInteger width = [self.navigationItem.leftBarButtonItem.title
                           boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                           options:NSStringDrawingUsesLineFragmentOrigin |
                           NSStringDrawingUsesFontLeading
                           attributes:@{
                                        NSFontAttributeName : [UIFont systemFontOfSize:17.0]
                                        }
                           context:nil]
        .size.width;
        return CGRectMake(5, 20, width + 6, 44);
    } else if ([coachMarkIdentifier isEqualToString:@"reorderTask"]) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
            
            UITableViewCell *cell;
            for (NSIndexPath *indexPath in visibleCells) {
                cell = [self.tableView cellForRowAtIndexPath:indexPath];
                CGRect frame = [self.tableView
                                convertRect:cell.frame
                                toView:self.parentViewController.parentViewController.view];
                if (frame.origin.y >= self.tableView.contentInset.top) {
                    return frame;
                }
            }
            return [self.tableView convertRect:cell.frame
                                        toView:self.parentViewController.parentViewController.view];
        }
    }
    return CGRectZero;
}

@end
