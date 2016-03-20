//
//  HRPGSettingsViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 13/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSettingsViewController.h"
#import "HRPGAppDelegate.h"
#import <PDKeychainBindings.h>
#import "HRPGTopHeaderNavigationController.h"
#import "XLForm.h"
#import "MRProgress.h"
#import "UIColor+Habitica.h"

@interface HRPGSettingsViewController ()
@property HRPGManager *sharedManager;
@property NSManagedObjectContext *managedObjectContext;
@property XLFormSectionDescriptor *reminderSection;
@end

@implementation HRPGSettingsViewController
NSUserDefaults *defaults;
User *user;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        HRPGAppDelegate *appdelegate =
            (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
        HRPGManager *sharedManager = appdelegate.sharedManager;
        self.managedObjectContext = sharedManager.getManagedObjectContext;
        defaults = [NSUserDefaults standardUserDefaults];
        user = [sharedManager getUser];
        self.username = user.username;

        [self initializeForm];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;

    HRPGTopHeaderNavigationController *navigationController =
        (HRPGTopHeaderNavigationController *)self.navigationController;
    [self.tableView
        setContentInset:UIEdgeInsetsMake([navigationController getContentInset], 0, 0, 0)];
    self.tableView.scrollIndicatorInsets =
        UIEdgeInsetsMake([navigationController getContentInset], 0, 0, 0);
    if (navigationController.state == HRPGTopHeaderStateHidden) {
        [self.tableView setContentOffset:CGPointMake(0, -[navigationController getContentOffset])];
    } else {
        [self.tableView setContentOffset:CGPointMake(0, -[navigationController getContentOffset])];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllData:)
                                                 name:@"shouldReloadAllData"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        [navigationController startFollowingScrollView:self.tableView withOffset:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        [navigationController stopFollowingScrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        [navigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
    }
}

- (void)reloadAllData:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)initializeForm {
    XLFormDescriptor *formDescriptor =
        [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Settings", nil)];

    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"User", nil)];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"accountDetail"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:NSLocalizedString(@"Account Details", nil)];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"logout"
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:NSLocalizedString(@"Log Out", nil)];
    [row.cellConfigAtConfigure setObject:[UIColor red100] forKey:@"textLabel.textColor"];
    [section addFormRow:row];

    self.reminderSection =
        [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Reminder", nil)];
    [formDescriptor addFormSection:self.reminderSection];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"useReminder"
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:NSLocalizedString(@"Daily Reminder", nil)];
    [self.reminderSection addFormRow:row];
    if ([defaults boolForKey:@"dailyReminderActive"]) {
        row.value = [NSNumber numberWithBool:YES];
        [self showDatePicker];
    }

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Day Start", nil)];
    [formDescriptor addFormSection:section];
    row =
        [XLFormRowDescriptor formRowDescriptorWithTag:@"dayStart"
                                              rowType:XLFormRowDescriptorTypeSelectorPickerView
                                                title:NSLocalizedString(@"Custom Day Start", nil)];
    [section addFormRow:row];

    NSMutableArray *hourOptions = [NSMutableArray arrayWithCapacity:23];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    for (int hour = 0; hour < 24; hour++) {
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d:00:00", hour]];
        [hourOptions
            addObject:
                [XLFormOptionsObject
                    formOptionsObjectWithValue:@(hour)
                                   displayText:
                                       [NSDateFormatter
                                           localizedStringFromDate:date
                                                         dateStyle:NSDateFormatterNoStyle
                                                         timeStyle:NSDateFormatterShortStyle]]];
    }
    row.selectorOptions = hourOptions;
    NSDate *currentDayStart = [dateFormatter
        dateFromString:[NSString stringWithFormat:@"%@:00:00", user.preferences.dayStart]];
    row.value = [XLFormOptionsObject
        formOptionsObjectWithValue:user.preferences.dayStart
                       displayText:[NSDateFormatter
                                       localizedStringFromDate:currentDayStart
                                                     dateStyle:NSDateFormatterNoStyle
                                                     timeStyle:NSDateFormatterShortStyle]];

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Maintenance", nil)];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"clearCache"
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:NSLocalizedString(@"Clear Cache", nil)];
    [row.cellConfigAtConfigure setObject:[UIColor red100] forKey:@"textLabel.textColor"];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reloadContent"
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:NSLocalizedString(@"Reload Content", nil)];
    [section addFormRow:row];

    self.form = formDescriptor;
}

- (void)showDatePicker {
    XLFormRowDescriptor *row =
        [XLFormRowDescriptor formRowDescriptorWithTag:@"reminderDate"
                                              rowType:XLFormRowDescriptorTypeTimeInline
                                                title:@"Every Day at"];
    if ([defaults valueForKeyPath:@"dailyReminderTime"]) {
        row.value = [defaults valueForKeyPath:@"dailyReminderTime"];
    } else {
        row.value = [NSDate date];
    }
    [self.reminderSection addFormRow:row];
}

- (void)hideDatePicker {
    [self.form removeFormRowWithTag:@"reminderDate"];
}

- (IBAction)reminderTimeChanged:(NSDate *)date {
    [defaults setValue:date forKey:@"dailyReminderTime"];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.repeatInterval = NSDayCalendarUnit;
    localNotification.alertBody = NSLocalizedString(@"Remember to check off your Dailies!", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)logoutUser {
    MRProgressOverlayView *overlayView = [MRProgressOverlayView
        showOverlayAddedTo:self.navigationController.parentViewController.view
                  animated:YES];
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [keyChain setString:@"" forKey:@"id"];
    [keyChain setString:@"" forKey:@"key"];
    [defaults setObject:@"" forKey:@"partyID"];
    [defaults setObject:@"" forKey:@"habitFilter"];
    [defaults setObject:@"" forKey:@"dailyFilter"];
    [defaults setObject:@"" forKey:@"todoFilter"];
    [self.sharedManager clearLoginCredentials];

    [self.sharedManager
        resetSavedDatabase:YES
                onComplete:^() {
                    [overlayView dismiss:YES
                              completion:^() {
                                  UIStoryboard *storyboard =
                                      [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  UINavigationController *navigationController =
                                      (UINavigationController *)[storyboard
                                          instantiateViewControllerWithIdentifier:
                                              @"loginNavigationController"];
                                  [self presentViewController:navigationController
                                                     animated:YES
                                                   completion:nil];
                              }];
                }];
}

- (void)resetCache {
    MRProgressOverlayView *overlayView = [MRProgressOverlayView
        showOverlayAddedTo:self.navigationController.parentViewController.view
                  animated:YES];
    [self.sharedManager resetSavedDatabase:YES
                                onComplete:^() {
                                    overlayView.mode = MRProgressOverlayViewModeCheckmark;
                                    dispatch_time_t popTime = dispatch_time(
                                        DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC));
                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                                        [overlayView dismiss:YES];
                                    });
                                }];
}

- (void)reloadContent {
    MRProgressOverlayView *overlayView = [MRProgressOverlayView
        showOverlayAddedTo:self.navigationController.parentViewController.view
                  animated:YES];
    [self.sharedManager fetchContent:^() {
        overlayView.mode = MRProgressOverlayViewModeCheckmark;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [overlayView dismiss:YES];
        });
    }
        onError:^() {
            overlayView.mode = MRProgressOverlayViewModeCross;
            overlayView.tintColor = [UIColor redColor];
            dispatch_time_t popTime =
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [overlayView dismiss:YES];
            });
        }];
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    [super didSelectFormRow:formRow];

    if ([formRow.tag isEqual:@"accountDetail"]) {
        [self performSegueWithIdentifier:@"AccountDetailSegue" sender:self];
    } else if ([formRow.tag isEqual:@"logout"]) {
        [self logoutUser];
        [self deselectFormRow:formRow];
    } else if ([formRow.tag isEqual:@"clearCache"]) {
        [self resetCache];
    } else if ([formRow.tag isEqual:@"reloadContent"]) {
        [self reloadContent];
    }

    [self deselectFormRow:formRow];
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor
                                oldValue:(id)oldValue
                                newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    if ([rowDescriptor.tag isEqualToString:@"useReminder"]) {
        if ([[rowDescriptor.value valueData] boolValue]) {
            [defaults setBool:YES forKey:@"dailyReminderActive"];
            [self showDatePicker];
        } else if ([[oldValue valueData] isEqualToNumber:@(0)] == NO &&
                   [[newValue valueData] isEqualToNumber:@(0)]) {
            [defaults setBool:NO forKey:@"dailyReminderActive"];
            [self hideDatePicker];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    } else if ([rowDescriptor.tag isEqualToString:@"reminderDate"]) {
        [self reminderTimeChanged:[rowDescriptor.value valueData]];
    } else if ([rowDescriptor.tag isEqualToString:@"dayStart"]) {
        XLFormOptionsObject *value = (XLFormOptionsObject *)newValue;
        [self.sharedManager updateUser:@{
            @"preferences.dayStart" : value.valueData
        }
                             onSuccess:nil
                               onError:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == 0 && indexPath.item == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return NSLocalizedString(@"Habitica defaults to check and reset your Dailies at midnight "
                                 @"in your own time zone each day. You can customize that time "
                                 @"here.",
                                 nil);
    }
    return [super tableView:tableView titleForFooterInSection:section];
}

@end
