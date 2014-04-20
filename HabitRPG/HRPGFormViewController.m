//
//  HRPGAddViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGFormViewController.h"
#import "Task.h"
#import "HRPGAppDelegate.h"
@interface HRPGFormViewController ()

@end

@implementation HRPGFormViewController
@synthesize managedObjectContext;
int selectedDifficulty;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appdelegate.sharedManager.getManagedObjectContext;
    
    if (!self.editTask) {
        self.task = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Task"
                    inManagedObjectContext:self.managedObjectContext];
        self.task.type = self.taskType;
    } else {
        if ([self.task.priority floatValue] == 1.0) {
            selectedDifficulty = 0;
        } else if ([self.task.priority floatValue] == 1.5) {
            selectedDifficulty = 1;
        } else if ([self.task.priority floatValue] == 2.0) {
            selectedDifficulty = 2;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITextField *textField = (UITextField*)[cell viewWithTag:2];
    [textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Task", nil);
            break;
        case 1:
            if ([self.taskType isEqualToString:@"habit"]) {
                return NSLocalizedString(@"Directions", nil);
            }
            return NSLocalizedString(@"Repeat", nil);
            break;
        case 2:
            return NSLocalizedString(@"Difficulty", nil);
            break;
        default:
            return @"";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            if ([self.taskType isEqualToString:@"habit"]) {
                return 2;
            }
            return 7;
            break;
        case 2:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0: {
            static NSString *CellIdentifier = @"TextInputCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            UITextField *textField = (UITextField*)[cell viewWithTag:2];
            
            if (indexPath.item == 0) {
                label.text = NSLocalizedString(@"Text", nil);
                if (self.editTask && textField.text.length == 0) {
                    textField.text = self.task.text;
                }
            } else if (indexPath.item == 1) {
                label.text = NSLocalizedString(@"Note", nil);
                if (self.editTask && textField.text.length == 0) {
                    textField.text = self.task.notes;
                }
            }
            break;
        }
        case 1: {
            if ([self.taskType isEqualToString:@"habit"]) {
                static NSString *CellIdentifier = @"SwitchCell";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                UISwitch *upDownSwitch = (UISwitch *)[cell viewWithTag:2];
                
                switch (indexPath.item) {
                    case 0:
                        label.text = NSLocalizedString(@"Up +", nil);
                        if (self.editTask) {
                            upDownSwitch.on = self.task.up;
                        }
                        break;
                    case 1:
                        label.text = NSLocalizedString(@"Down -", nil);
                        if (self.editTask) {
                            upDownSwitch.on = self.task.down;
                        }
                        break;
                }
                
            } else {
                static NSString *CellIdentifier = @"CheckMarkCell";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                
                switch (indexPath.item) {
                    case 0:
                        label.text = NSLocalizedString(@"Monday", nil);
                        if (self.editTask && self.task.monday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case 1:
                        label.text = NSLocalizedString(@"Tuesday", nil);
                        if (self.editTask && self.task.tuesday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case 2:
                        label.text = NSLocalizedString(@"Wednesday", nil);
                        if (self.editTask && self.task.wednesday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case 3:
                        label.text = NSLocalizedString(@"Thursday", nil);
                        if (self.editTask && self.task.thursday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case 4:
                        label.text = NSLocalizedString(@"Friday", nil);
                        if (self.editTask && self.task.friday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case 5:
                        label.text = NSLocalizedString(@"Saturday", nil);
                        if (self.editTask && self.task.saturday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case 6:
                        label.text = NSLocalizedString(@"Sunday", nil);
                        if (self.editTask && self.task.sunday) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                }
            }
            break;
        }
        case 2: {
            static NSString *CellIdentifier = @"CheckMarkCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            
            switch (indexPath.item) {
                case 0: label.text = NSLocalizedString(@"Easy", nil); break;
                case 1: label.text = NSLocalizedString(@"Medium", nil); break;
                case 2: label.text = NSLocalizedString(@"Hard", nil); break;
            }
            if (indexPath.item == selectedDifficulty) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && ![self.taskType isEqualToString:@"habit"]) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

        switch (indexPath.item) {
            case 0: self.task.monday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
            case 1: self.task.tuesday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
            case 2: self.task.wednesday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
            case 3: self.task.thursday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
            case 4: self.task.friday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
            case 5: self.task.saturday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
            case 6: self.task.sunday = (cell.accessoryType == UITableViewCellAccessoryCheckmark); break;
        }
    } else if (indexPath.section == 2) {
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:selectedDifficulty inSection:indexPath.section]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedDifficulty = indexPath.item;
        switch (selectedDifficulty) {
            case 0: self.task.priority = [NSNumber numberWithFloat:1.0]; break;
            case 1: self.task.priority = [NSNumber numberWithFloat:1.5]; break;
            case 2: self.task.priority = [NSNumber numberWithFloat:2.0]; break;
        }
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"unwindSaveSegue"]) {
        UITextField *textField = (UITextField*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] viewWithTag:2];
        self.task.text = textField.text;
        UITextField *noteField = (UITextField*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]] viewWithTag:2];
        self.task.notes = noteField.text;
        if ([self.taskType isEqualToString:@"habit"]) {
            UISwitch *upSwitch = (UISwitch*) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]] viewWithTag:2];

            self.task.up = upSwitch.on;
        
            UISwitch *downSwitch = (UISwitch*) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]] viewWithTag:2];
            self.task.down = downSwitch.on;
        }
    } else if([segue.identifier isEqualToString:@"unwindCancelSegue"]) {
        if (!self.editTask) {
            [managedObjectContext deleteObject:self.task];
        } else {
            [managedObjectContext refreshObject:self.task mergeChanges:NO];
            
        }
    }
}
@end
