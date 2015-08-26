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
@property NSInteger dayStart;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic openedIndexPath;
@dynamic indexOffset;
NIKFontAwesomeIconFactory *streakIconFactory;

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
    
    streakIconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    streakIconFactory.square = YES;
    streakIconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dayStart = [[self.sharedManager getUser].dayStart integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    UILabel *v = (UILabel *) [cell viewWithTag:2];
    [v.layer setCornerRadius:5.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
        // Listing of the tag numbers [cell viewWithTag:#]
        //  1 = label (on SB: lbl_daily)
        //  2 = checklistLabel (on SB: lbl_checklistLabel)  // this should be removed once the checklistButton is done
        //  3 = checkBox
        //  4 = streakLabel (on SB: lbl_streakLabel
        //  5 = checklistButton (on SB: btn_checklistButton)
        //  6 = streakImage (on SB: img_streakImage)
        //  7 = View (on SB: View)
        //
        //  Lines that have the comment "to be removed once checklistButton is done" refer to having the checklistButton have the same look as checklistLabel while still filling the full end of the cell
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    UILabel *checklistLabel = (UILabel *) [cell viewWithTag:2]; // to be removed once checklistButton done
    HRPGCheckBoxView *checkBox = (HRPGCheckBoxView *) [cell viewWithTag:3];
    UILabel *streakLabel = (UILabel *) [cell viewWithTag:4];
    UIButton *checklistButton = (UIButton *) [cell viewWithTag:5];
    UIImageView *streakImage = (UIImageView *) [cell viewWithTag:6];
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
        streakLabel.hidden = YES;
        checklistLabel.hidden = YES;    // to be removed once checklistButton done
        [checklistButton setHidden:YES];
        cell.backgroundColor = [UIColor lightGrayColor];
        checkBox.boxColor = [UIColor darkGrayColor];
        checkBox.checkColor = [UIColor lightGrayColor];
        if ([item.completed boolValue]) {
            self.checkIconFactory.colors = @[[UIColor whiteColor]];
            label.textColor = [UIColor whiteColor];
            checkBox.wasTouched = ^() {
                if (![task.currentlyChecking boolValue]) {
                    task.currentlyChecking = [NSNumber numberWithBool:YES];
                    item.completed = [NSNumber numberWithBool:NO];
                    [self addActivityCounter];
                    [self.sharedManager updateTask:task onSuccess:^() {
                        [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                        NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                        [self configureCell:[self.tableView cellForRowAtIndexPath:taskPath] atIndexPath:taskPath withAnimation:YES];
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }                      onError:^() {
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }];
                }

            };
            [checkBox setChecked:YES animated:YES];
        } else {
            label.textColor = [UIColor whiteColor];
            checkBox.wasTouched = ^() {
                if (![task.currentlyChecking boolValue]) {
                    task.currentlyChecking = [NSNumber numberWithBool:YES];
                    item.completed = [NSNumber numberWithBool:YES];
                    [self addActivityCounter];
                    [self.sharedManager updateTask:task onSuccess:^() {
                        [self configureCell:cell atIndexPath:indexPath withAnimation:YES];
                        NSIndexPath *taskPath = [self indexPathForTaskWithOffset:indexPath];
                        [self configureCell:[self.tableView cellForRowAtIndexPath:taskPath] atIndexPath:taskPath withAnimation:YES];
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }                      onError:^() {
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }];
                }

            };
            [checkBox setChecked:NO animated:YES];
        }

    } else {
        label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        streakLabel.text = [task.streak stringValue];
        streakLabel.hidden = NO;
        if ([task.streak isEqualToNumber:[NSNumber numberWithInt:0]]) {
            streakLabel.textColor = [UIColor lightGrayColor];  // set text color to light gray if not currently on a streak
            streakIconFactory.colors = @[[UIColor lightGrayColor]];
        }
        else {
            streakLabel.textColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];  // set text color to green if currently on a streak
            streakIconFactory.colors = @[[UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000]];
        }
        
        streakIconFactory.size = 16.0f;
        streakImage.image = [streakIconFactory createImageForIcon:NIKFontAwesomeIconForward];
        
        NSNumber *checklistCount = [task valueForKeyPath:@"checklist.@count"];
        if ([checklistCount integerValue] > 0) {
            int checkedCount = 0;
            for (ChecklistItem *item in [task checklist]) {
                if ([item.completed boolValue]) {
                    checkedCount++;
                }
            }
            checklistLabel.text = [NSString stringWithFormat:@"%d/%@", checkedCount, checklistCount]; // to be removed once checklistButton is done
            //[checklistButton setTitle:[NSString stringWithFormat:@"%d/%@", checkedCount, checklistCount] forState:UIControlStateNormal];
            if (checkedCount == [checklistCount integerValue]) {
                checklistLabel.backgroundColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];   // to be removed once checklistButton is done
                //[checklistButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000]];
            } else {
                checklistLabel.backgroundColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]; // to be removed once checklistButton is done
                //[checklistButton setBackgroundColor:[UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]];
            }
            checklistLabel.hidden = NO;    // to be removed once checklistButton is done
            [checklistButton setHidden:NO];
            UITapGestureRecognizer *btnTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandSelectedCell:)];
            btnTapRecognizer.numberOfTapsRequired = 1;
            [checklistButton addGestureRecognizer:btnTapRecognizer];
        } else {
            checklistLabel.hidden = YES;    // remove once checklistButton is done
            [checklistButton setHidden:YES];
        }
        
        if ([task.completed boolValue]) {
            checkBox.boxColor = [UIColor colorWithWhite:0.705 alpha:1.000];
            checkBox.checkColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            self.checkIconFactory.colors = @[[UIColor darkGrayColor]];
            label.textColor = [UIColor darkGrayColor];
            cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            [checkBox setChecked:YES animated:YES];
            checkBox.wasTouched = ^() {
                if (![task.currentlyChecking boolValue]) {
                    [self addActivityCounter];
                    task.currentlyChecking = [NSNumber numberWithBool:YES];
                    [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(NSArray *valuesArray) {
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }onError:^() {
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }];
                }
            };
        } else {
            checkBox.wasTouched = ^() {
                if (![task.currentlyChecking boolValue]) {
                    [self addActivityCounter];
                    task.currentlyChecking = [NSNumber numberWithBool:YES];
                    [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(NSArray *valuesArray) {
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }onError:^() {
                        task.currentlyChecking = [NSNumber numberWithBool:NO];
                        [self removeActivityCounter];
                    }];
                }
            };
            [checkBox setChecked:NO animated:YES];
            if (![task dueTodayWithOffset:self.dayStart]) {
                checkBox.boxColor = [UIColor lightGrayColor];
                label.textColor = [UIColor darkGrayColor];
                cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.000];
            } else {
                checkBox.boxColor = [[task taskColor] darkerColor];
                cell.backgroundColor = [task lightTaskColor];
                label.textColor = [UIColor blackColor];
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
