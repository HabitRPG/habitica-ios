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
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import "NSString+Emoji.h"
#import "UIColor+LighterDarker.h"
#import "HRPGCheckBoxView.h"

@interface HRPGToDoTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NIKFontAwesomeIconFactory *iconFactory;
@property NIKFontAwesomeIconFactory *checkIconFactory;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property NSDateFormatter *dateFormatter;
@end

@implementation HRPGToDoTableViewController

@dynamic readableName;
@dynamic typeName;
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
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    UILabel *footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
    footerView.text = NSLocalizedString(@"Show completed To-Dos", nil);
    footerView.textAlignment = NSTextAlignmentCenter;
    footerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    footerView.textColor = [UIColor colorWithRed:0.837 green:0.652 blue:0.238 alpha:1.000];
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(toggleCompletedTasks:)];
    [footerView setUserInteractionEnabled:YES];
    [footerView addGestureRecognizer:singleFingerTap];
    
    self.tableView.tableFooterView = footerView;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        // remove this once the checklistButton is done
    UILabel *v = (UILabel *) [cell viewWithTag:2];
    // border radius
    [v.layer setCornerRadius:5.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.displayCompleted && section == (self.tableView.numberOfSections-1)) {
        return 45;
    }
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.displayCompleted && section == (self.tableView.numberOfSections-1)) {
        return [self toggleViewWithText:NSLocalizedString(@"Hide completed To-Dos", nil)];
    }
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
        // listing of the tag numbers [cell viewWithTag:#]
        //  1 = label
        //  2 = checklistLabel  // to be removed once checklistButton is done
        //  3 = checkBox
        //  4 = subLabel
        //  5 = checklistButton
        //
        //  Lines that have the comment "to be removed once checklistButton is done" refer to having the checklistButton have the same look as checklistLabel while still filling the full end of the cell
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    UILabel *checklistLabel = (UILabel *) [cell viewWithTag:2]; // to be removed once checklistButton is done
    HRPGCheckBoxView *checkBox = (HRPGCheckBoxView *) [cell viewWithTag:3];
    UILabel *subLabel = (UILabel *) [cell viewWithTag:4];
    UIButton *checklistButton = (UIButton *) [cell viewWithTag:5];
    if (checkBox == nil) {
        checkBox = [[HRPGCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 50, cell.frame.size.height)];
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
        checklistLabel.hidden = YES; // to be removed once checklistButton is done
        [checklistButton setHidden:YES];
        cell.backgroundColor = [UIColor lightGrayColor];
        checkBox.boxColor = [UIColor darkGrayColor];
        checkBox.checkColor = [UIColor lightGrayColor];
        subLabel.hidden = YES;
        if ([item.completed boolValue]) {
            self.checkIconFactory.colors = @[[UIColor whiteColor]];
            label.textColor = [UIColor darkTextColor];
            checkBox.wasTouched = ^() {
                item.completed = [NSNumber numberWithBool:NO];
                [self addActivityCounter];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                    NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                    [self configureCell:[self.tableView cellForRowAtIndexPath:taskPath] atIndexPath:taskPath withAnimation:YES];
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
                    NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                    [self configureCell:[self.tableView cellForRowAtIndexPath:taskPath] atIndexPath:taskPath withAnimation:YES];
                    [self removeActivityCounter];
                }                      onError:^() {
                    [self removeActivityCounter];
                }];
                
            };
            [checkBox setChecked:NO animated:YES];
        }
        
    } else {
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
            checklistLabel.text = [NSString stringWithFormat:@"%d/%@", checkedCount, checklistCount]; // to be removed once checklisButton is done
            //[checklistButton setTitle:[NSString stringWithFormat:@"%d/%@", checkedCount, checklistCount] forState:UIControlStateNormal];
            if (checkedCount == [checklistCount integerValue]) {
                checklistLabel.backgroundColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];   // to be removed once checklistButton is done
                //[checklistButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000]];
            } else {
                checklistLabel.backgroundColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]; // to be removed once checklistButton is done
                //[checklistButton setBackgroundColor:[UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]];
            }
            checklistLabel.hidden = NO; // to be removed once checklistButton is done
            [checklistButton setHidden:NO];
                // remove next three lines once checklistButton is done
            //UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandSelectedCell:)];
            //tapRecognizer.numberOfTapsRequired = 1;
            //[checklistLabel addGestureRecognizer:tapRecognizer];
            UITapGestureRecognizer *btnTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandSelectedCell:)];
            btnTapRecognizer.numberOfTapsRequired = 1;
            [checklistButton addGestureRecognizer:btnTapRecognizer];
        } else {
            checklistLabel.hidden = YES; // to be removed once checklistButton is done
            [checklistButton setHidden:YES];
        }
        
        if ([task.completed boolValue]) {
            checkBox.boxColor = [UIColor lightGrayColor];
            checkBox.checkColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            self.checkIconFactory.colors = @[[UIColor darkGrayColor]];
            label.textColor = [UIColor darkGrayColor];
            cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            [checkBox setChecked:YES animated:YES];
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
                checkBox.checkColor = [UIColor colorWithWhite:0.85 alpha:1.000];
                label.textColor = [UIColor darkGrayColor];
                cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            } else {
                checkBox.boxColor = [[task taskColor] darkerColor];
                checkBox.checkColor = [task lightTaskColor];
                cell.backgroundColor = [task lightTaskColor];
                label.textColor = [UIColor blackColor];
            }
        }
        
        if (task.duedate) {
            subLabel.hidden = NO;
            subLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
            [components setHour:0];
            NSDate *today = [calendar dateFromComponents:components];
            if ([task.duedate compare:today] == NSOrderedAscending) {
                if (![task.completed boolValue]) {
                    cell.backgroundColor = [UIColor colorWithRed:0.824 green:0.600 blue:0.545 alpha:1.000];
                    checkBox.boxColor = [UIColor colorWithRed:0.725 green:0.176 blue:0.188 alpha:1.000];
                }
                subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due %@", nil), [self.dateFormatter stringFromDate:task.duedate]];
            } else {
                subLabel.textColor = [UIColor grayColor];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *differenceValue = [calendar components:NSCalendarUnitDay
                                                                fromDate:today toDate:task.duedate options:0];
                if ([differenceValue day] < 7) {
                    if ([differenceValue day] == 0) {
                        subLabel.textColor = [UIColor colorWithRed:0.725 green:0.176 blue:0.188 alpha:1.000];
                        subLabel.text = NSLocalizedString(@"Due today", nil);
                    } else if ([differenceValue day] == 1) {
                        subLabel.text = NSLocalizedString(@"Due tomorrow", nil);
                    } else {
                        subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due in %d days", nil), [differenceValue day]];
                    }
                } else {
                    subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due until %@", nil), [self.dateFormatter stringFromDate:task.duedate]];
                }
            }
        }
    }
}


- (void)toggleCompletedTasks:(UITapGestureRecognizer*)tapRecognizer {
    self.displayCompleted = !self.displayCompleted;
    [self.fetchedResultsController.fetchRequest setPredicate:[self getPredicate]];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (self.displayCompleted) {
        if (self.fetchedResultsController.sections.count == 0) {
            return;
        }
        UILabel *footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
        footerView.text = NSLocalizedString(@"Clear completed To-Dos", nil);
        footerView.textAlignment = NSTextAlignmentCenter;
        footerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        footerView.textColor = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, footerView.frame.size.height, footerView.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        [footerView.layer addSublayer:bottomBorder];
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0f, -1.0f, footerView.frame.size.width, 1.0f);
        topBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        [footerView.layer addSublayer:topBorder];

        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(clearCompletedTasks:)];
        [footerView setUserInteractionEnabled:YES];
        [footerView addGestureRecognizer:singleFingerTap];
        self.tableView.tableFooterView = footerView;

        NSIndexSet *index = [NSIndexSet indexSetWithIndex:[self.tableView numberOfSections]];
        [self.tableView insertSections:index withRowAnimation:UITableViewRowAnimationBottom];
    } else {
        self.tableView.tableFooterView = [self toggleViewWithText:NSLocalizedString(@"Show completed To-Dos", nil)];
        
        if (self.fetchedResultsController.sections.count == 0) {
            if (self.tableView.numberOfSections == 1) {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            }
            return;
        }
        NSIndexSet *index = [NSIndexSet indexSetWithIndex:1];
        [self.tableView deleteSections:index withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)clearCompletedTasks:(UITapGestureRecognizer*)tapRecognizer {
    [self toggleCompletedTasks:nil];
    [self.sharedManager clearCompletedTasks:^(){
        [self.sharedManager fetchUser:^() {
            
        }onError:^() {
            
        }];
    }onError:^() {
        
    }];
}

- (void) expandSelectedCell:(UITapGestureRecognizer*)gesture {
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    [self tableView:self.tableView expandTaskAtIndexPath:indexPath];
}

- (UILabel*) toggleViewWithText:(NSString*)text {
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
    view.text = text;
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    view.textColor = [UIColor colorWithRed:0.478 green:0.071 blue:0.973 alpha:1.000];
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(toggleCompletedTasks:)];
    [view setUserInteractionEnabled:YES];
    [view addGestureRecognizer:singleFingerTap];
    
    return view;
}

@end
