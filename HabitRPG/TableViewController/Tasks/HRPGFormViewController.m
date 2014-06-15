//
//  HRPGAddViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGFormViewController.h"
#import "ChecklistItem.h"
#import "NSString+Emoji.h"

@interface HRPGFormViewController ()

@end

@implementation HRPGFormViewController
@synthesize managedObjectContext;
int selectedDifficulty;
BOOL displayDatePicker;
NSDateFormatter *dateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.editTask) {
        self.task = [NSEntityDescription
                insertNewObjectForEntityForName:@"Task"
                         inManagedObjectContext:self.managedObjectContext];
        self.task.priority = [NSNumber numberWithFloat:1.0f];
        selectedDifficulty = 0;
    } else {
        if ([self.task.priority floatValue] == 1.0) {
            selectedDifficulty = 0;
        } else if ([self.task.priority floatValue] == 1.5) {
            selectedDifficulty = 1;
        } else if ([self.task.priority floatValue] == 2.0) {
            selectedDifficulty = 2;
        }
    }

    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    displayDatePicker = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITextField *textField = (UITextField *) [cell viewWithTag:2];
    [textField becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (![self.taskType isEqualToString:@"habit"]) {
        return 4;
    }
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Task", nil);
    } else if (section == 1 && [self.taskType isEqualToString:@"habit"]) {
        return NSLocalizedString(@"Directions", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Checklist", nil);
    } else if (section == 2 && [self.taskType isEqualToString:@"daily"]) {
        return NSLocalizedString(@"Repeat", nil);
    } else if (section == 2 && [self.taskType isEqualToString:@"todo"]) {
        return NSLocalizedString(@"Due Date", nil);
    } else {
        return NSLocalizedString(@"Difficulty", nil);
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1 && [self.taskType isEqualToString:@"habit"]) {
        return 2;
    } else if (section == 1) {
        return [self.task.checklist count] + 1;
    } else if (section == 2 && [self.taskType isEqualToString:@"daily"]) {
        return 7;
    } else if (section == 2 && [self.taskType isEqualToString:@"todo"]) {
        if (self.task.duedate) {
            if (displayDatePicker) {
                return 3;
            } else {
                return 2;
            }
        } else {
            return 1;
        }
    } else if ((section == 3 && ![self.taskType isEqualToString:@"habit"]) || section == 2) {
        return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.taskType isEqualToString:@"todo"] && indexPath.section == 2 && indexPath.item == 2) {
        return 210;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"TextInputCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        UITextField *textField = (UITextField *) [cell viewWithTag:2];
        textField.delegate = self;
        if (indexPath.item == 0) {
            label.text = NSLocalizedString(@"Text", nil);
            textField.text = [self.task.text stringByReplacingEmojiCheatCodesWithUnicode];
        } else if (indexPath.item == 1) {
            label.text = NSLocalizedString(@"Note", nil);
            textField.text = [self.task.notes stringByReplacingEmojiCheatCodesWithUnicode];
        }
    } else if (indexPath.section == 1 && [self.taskType isEqualToString:@"habit"]) {
        static NSString *CellIdentifier = @"SwitchCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        UISwitch *upDownSwitch = (UISwitch *) [cell viewWithTag:2];

        switch (indexPath.item) {
            case 0:
                label.text = NSLocalizedString(@"Up +", nil);
                upDownSwitch.on = [self.task.up boolValue];
                break;
            case 1:
                label.text = NSLocalizedString(@"Down -", nil);
                upDownSwitch.on = [self.task.down boolValue];
                break;
        }
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextInputAltCell" forIndexPath:indexPath];
        UITextField *textField = (UITextField *) [cell viewWithTag:1];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyNext;

        if (indexPath.item < [self.task.checklist count]) {
            ChecklistItem *item = self.task.checklist[indexPath.item];
            textField.text = item.text;
        }
    } else if (indexPath.section == 2 && [self.taskType isEqualToString:@"daily"]) {
        static NSString *CellIdentifier = @"CheckMarkCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *label = (UILabel *) [cell viewWithTag:1];

        switch (indexPath.item) {
            case 0:
                label.text = NSLocalizedString(@"Monday", nil);
                if ([self.task.monday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 1:
                label.text = NSLocalizedString(@"Tuesday", nil);
                if ([self.task.tuesday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 2:
                label.text = NSLocalizedString(@"Wednesday", nil);
                if ([self.task.wednesday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 3:
                label.text = NSLocalizedString(@"Thursday", nil);
                if ([self.task.thursday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 4:
                label.text = NSLocalizedString(@"Friday", nil);
                if ([self.task.friday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 5:
                label.text = NSLocalizedString(@"Saturday", nil);
                if ([self.task.saturday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 6:
                label.text = NSLocalizedString(@"Sunday", nil);
                if ([self.task.sunday boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
        }
    } else if (indexPath.section == 2 && [self.taskType isEqualToString:@"todo"]) {
        if (indexPath.item == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            UILabel *label = (UILabel *) [cell viewWithTag:1];
            UISwitch *dateSwitch = (UISwitch *) [cell viewWithTag:2];
            label.text = NSLocalizedString(@"Due Date", nil);
            dateSwitch.on = !(self.task.duedate == nil);
            [dateSwitch addTarget:self action:@selector(changeDueDateSwitch:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.item == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
            cell.detailTextLabel.text = [dateFormatter stringFromDate:self.task.duedate];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerCell" forIndexPath:indexPath];
            UIDatePicker *datePicker = (UIDatePicker *) [cell viewWithTag:1];
            datePicker.date = self.task.duedate;
        }
    } else {
        static NSString *CellIdentifier = @"CheckMarkCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UILabel *label = (UILabel *) [cell viewWithTag:1];

        switch (indexPath.item) {
            case 0:
                label.text = NSLocalizedString(@"Easy", nil);
                break;
            case 1:
                label.text = NSLocalizedString(@"Medium", nil);
                break;
            case 2:
                label.text = NSLocalizedString(@"Hard", nil);
                break;
        }
        if (indexPath.item == selectedDifficulty) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item < ([tableView numberOfRowsInSection:indexPath.section] - 1) && ![self.task.type isEqualToString:@"habit"]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item < ([tableView numberOfRowsInSection:indexPath.section] - 1) && ![self.task.type isEqualToString:@"habit"]) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            ChecklistItem *item = self.task.checklist[indexPath.item];
            [self.task removeChecklistObject:item];
            [self.managedObjectContext deleteObject:item];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


    // fix for separators bug in iOS 7
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 2 && [self.taskType isEqualToString:@"daily"]) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

        switch (indexPath.item) {
            case 0:
                self.task.monday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
            case 1:
                self.task.tuesday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
            case 2:
                self.task.wednesday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
            case 3:
                self.task.thursday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
            case 4:
                self.task.friday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
            case 5:
                self.task.saturday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
            case 6:
                self.task.sunday = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
                break;
        }
    } else if (indexPath.section == 2 && [self.taskType isEqualToString:@"todo"]) {
        if (indexPath.item == 1) {
            displayDatePicker = !displayDatePicker;
            if (displayDatePicker) {
                [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
            } else {
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
    } else if ((indexPath.section == 3 && ![self.taskType isEqualToString:@"habit"]) || indexPath.section == 2) {
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:selectedDifficulty inSection:indexPath.section]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedDifficulty = (int) indexPath.item;
        switch (selectedDifficulty) {
            case 0:
                self.task.priority = [NSNumber numberWithFloat:1.0];
                break;
            case 1:
                self.task.priority = [NSNumber numberWithFloat:1.5];
                break;
            case 2:
                self.task.priority = [NSNumber numberWithFloat:2.0];
                break;
        }
    }
}

#pragma mark - TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section]];
    UITextView *nextTextView = (UITextView *) [nextCell viewWithTag:1];
    [nextTextView becomeFirstResponder];
    return NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text isEqualToString:@""] && ![string isEqualToString:@""]) {
        UITableViewCell *cell = (UITableViewCell *) textField.superview.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSInteger itemCount = [self.tableView numberOfRowsInSection:indexPath.section];
        if ((itemCount - 1) == indexPath.item) {
            ChecklistItem *item = [NSEntityDescription
                    insertNewObjectForEntityForName:@"ChecklistItem"
                             inManagedObjectContext:self.managedObjectContext];
            [self.task addChecklistObject:item];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    if (indexPath.section == 0 && indexPath.item == 0) {
        self.task.text = textField.text;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        self.task.notes = textField.text;
    } else {
        ChecklistItem *item;
        if ([self.task.checklist count] > indexPath.item) {
            item = self.task.checklist[indexPath.item];
        }
        if ([textField.text isEqualToString:@""]) {
            if (indexPath.item < [self.task.checklist count]) {
                [self.task removeChecklistObject:item];
                [self.managedObjectContext deleteObject:item];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
            }
        } else {
            item.text = textField.text;
        }
    }
}

- (IBAction)datePickerChanged:(UIDatePicker *)datePicker {
    self.task.duedate = datePicker.date;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)changeDueDateSwitch:(UISwitch *)sender {
    if (sender.on) {
        self.task.duedate = [NSDate date];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.task.duedate = nil;
        NSArray *deleteArray;
        if (displayDatePicker) {
            displayDatePicker = NO;
            deleteArray = @[[NSIndexPath indexPathForItem:1 inSection:2], [NSIndexPath indexPathForItem:2 inSection:2]];
        } else {
            deleteArray = @[[NSIndexPath indexPathForItem:1 inSection:2]];
        }
        [self.tableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"unwindSaveSegue"]) {
        if (!self.editTask) {
            self.task.type = self.taskType;
        }
        if ([self.taskType isEqualToString:@"habit"]) {
            UISwitch *upSwitch = (UISwitch *) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]] viewWithTag:2];

            self.task.up = [NSNumber numberWithBool:upSwitch.on];

            UISwitch *downSwitch = (UISwitch *) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]] viewWithTag:2];
            self.task.down = [NSNumber numberWithBool:downSwitch.on];
        } else {
            for (int i = 0; i < [self.task.checklist count]; i++) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:1]];
                UITextField *textField = (UITextField *) [cell viewWithTag:1];
                ChecklistItem *item = self.task.checklist[i];
                item.text = textField.text;
                item.task = self.task;
            }
        }
    } else if ([segue.identifier isEqualToString:@"unwindCancelSegue"]) {
        if (!self.editTask) {
            [managedObjectContext deleteObject:self.task];
        } else {
            [managedObjectContext refreshObject:self.task mergeChanges:NO];

        }
    }
}
@end
