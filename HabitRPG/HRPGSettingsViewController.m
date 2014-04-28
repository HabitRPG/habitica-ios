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
    _sharedManager = appdelegate.sharedManager;
    user = [_sharedManager getUser];
    
    self.managedObjectContext = _sharedManager.getManagedObjectContext;
    defaults = [NSUserDefaults standardUserDefaults];
    reminder = [defaults boolForKey:@"dailyReminderActive"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
        return cell;
    }
    
    NSString *title = nil;
    NSString *identifier = @"Cell";
    if (indexPath.section == 0 && indexPath.item == 0) {
        title = [NSString stringWithFormat:NSLocalizedString(@"Logged in as: %@", nil), user.username];
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        title = NSLocalizedString(@"Log out", nil);
        identifier = @"LogoutCell";
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        title = NSLocalizedString(@"Daily Reminder", nil);
        identifier = @"SwitchCell";
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
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"%@", picker.date);
}

-(void)logoutUser {
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [keyChain setString:@"" forKey:@"id"];
    [keyChain setString:@"" forKey:@"key"];
    [defaults setObject:@"" forKey:@"partyID"];
    [_sharedManager resetSavedDatabase];
    
    [_sharedManager fetchContent:^() {
        
    }onError:^() {
        
    }];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [self presentViewController:navigationController animated:NO completion: nil];
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
