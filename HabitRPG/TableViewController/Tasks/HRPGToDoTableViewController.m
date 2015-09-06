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
#import "HRPGToDoTableViewCell.h"

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

- (void)configureCell:(HRPGToDoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
        // listing of the tag numbers [cell viewWithTag:#]
        //  1 = label
        //  2 = checklistLabel  // to be removed once checklistButton is done
        //  3 = checkBox
        //  4 = subLabel
        //  5 = checklistButton
        //
        //  Lines that have the comment "to be removed once checklistButton is done" refer to having the checklistButton have the same look as checklistLabel while still filling the full end of the cell
    
    Task *task = [self taskAtIndexPath:indexPath];
    
    cell.dateFormatter = self.dateFormatter;
    
    if (self.openedIndexPath && self.openedIndexPath.item < indexPath.item && indexPath.item <= (self.openedIndexPath.item + self.indexOffset)) {
        int currentOffset = (int) (indexPath.item - self.openedIndexPath.item - 1);
        
        ChecklistItem *item;
        if ([task.checklist count] > currentOffset) {
            item = task.checklist[currentOffset];
        }
        [cell configureForItem:item forTask:task];
        cell.checkBox.wasTouched = ^() {
            if (![task.currentlyChecking boolValue]) {
                task.currentlyChecking = [NSNumber numberWithBool:YES];
                item.completed = [NSNumber numberWithBool:![item.completed boolValue]];
                [self.sharedManager updateTask:task onSuccess:^() {
                    [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                    NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                    [self configureCell:(HRPGToDoTableViewCell *)[self.tableView cellForRowAtIndexPath:taskPath] atIndexPath:taskPath withAnimation:YES];
                    task.currentlyChecking = [NSNumber numberWithBool:NO];
                }                      onError:^() {
                    task.currentlyChecking = [NSNumber numberWithBool:NO];
                }];
            }
        };
    } else {
        [cell configureForTask:task];
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
