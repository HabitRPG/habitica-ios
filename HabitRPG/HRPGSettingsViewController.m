//
//  HRPGSettingsViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 13/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSettingsViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "User.h"
#import <PDKeychainBindings.h>

@interface HRPGSettingsViewController ()
@property HRPGManager *sharedManager;

@end

@implementation HRPGSettingsViewController
NSUserDefaults *defaults;
@synthesize managedObjectContext;
User *user;
BOOL reminder;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    user = [_sharedManager getUser];
    self.username = user.username;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = _sharedManager.getManagedObjectContext;
    defaults = [NSUserDefaults standardUserDefaults];
    reminder = [defaults boolForKey:@"dailyReminderActive"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            if (reminder) {
                return 2;
            } else {
                return 1;
            }
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 1) {
        return 210;
    }
    return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"User";
        case 1:
            return @"Reminder";
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.item == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateCell" forIndexPath:indexPath];
        NSDate *reminderTime = [defaults valueForKey:@"dailyReminderTime"];
        if (reminderTime) {
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:1];
            datePicker.date = reminderTime;
        }
        return cell;
    }
    
    NSString *title = nil;
    NSString *identifier = @"Cell";
    if (indexPath.section == 0 && indexPath.item == 0) {
        title = [NSString stringWithFormat:NSLocalizedString(@"Logged in as: %@", nil), self.username];
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        title = NSLocalizedString(@"Log out", nil);
        identifier = @"LogoutCell";
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        title = NSLocalizedString(@"Daily Reminder", nil);
        identifier = @"SwitchCell";
    } else if (indexPath.section == 2) {
        title = NSLocalizedString(@"Reset Cache", nil);
        identifier = @"LogoutCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = title;
    
    if (indexPath.section == 1 && indexPath.item == 0) {
        UISwitch *cellSwitch = (UISwitch*)[cell viewWithTag:2];
        cellSwitch.on = reminder;
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 1) {
        [self logoutUser];
    } else if (indexPath.section == 2) {
        [self resetCache];
    }
}

- (IBAction)reminderChanged:(UISwitch*)sender {
    [defaults setBool:sender.on forKey:@"dailyReminderActive"];
    reminder = sender.on;
    if (reminder) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (IBAction)reminderTimeChanged:(UIDatePicker*)picker {
    [defaults setValue:picker.date forKey:@"dailyReminderTime"];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = picker.date;
    localNotification.repeatInterval = NSDayCalendarUnit;
    localNotification.alertBody = NSLocalizedString(@"Don't forget to mark your todos!", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"%@", picker.date);
}

-(void)logoutUser {
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [keyChain setString:@"" forKey:@"id"];
    [keyChain setString:@"" forKey:@"key"];
    [defaults setObject:@"" forKey:@"partyID"];
    [_sharedManager resetSavedDatabase:NO];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [self presentViewController:navigationController animated:YES completion: nil];
}

-(void)resetCache {
    [_sharedManager resetSavedDatabase:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
