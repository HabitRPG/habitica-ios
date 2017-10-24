//
//  HRPGSettingsViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 13/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGSettingsViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGClassTableViewController.h"
#import "HRPGTopHeaderNavigationController.h"
#import "MRProgress.h"
#import "UIColor+Habitica.h"
#import "XLForm.h"
#import "HRPGPushNotificationSettingValueTransformer.h"
#import "Habitica-Swift.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"

@interface HRPGSettingsViewController ()
@property NSManagedObjectContext *managedObjectContext;
@property XLFormSectionDescriptor *reminderSection;
@property XLFormSectionDescriptor *appBadgeSection;
@property XLFormRowDescriptor *pushNotificationRow;
@end

@implementation HRPGSettingsViewController
NSUserDefaults *defaults;
User *user;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
        defaults = [NSUserDefaults standardUserDefaults];
        user = [[HRPGManager sharedManager] getUser];
        self.username = user.username;

        [self initializeForm];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView
        setContentInset:UIEdgeInsetsMake([[self hrpgTopHeaderNavigationController] getContentInset], 0, 0, 0)];
    self.tableView.scrollIndicatorInsets =
        UIEdgeInsetsMake([[self hrpgTopHeaderNavigationController] getContentInset], 0, 0, 0);
    [self.tableView setContentOffset:CGPointMake(0, -[[self hrpgTopHeaderNavigationController] getContentOffset])];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllData:)
                                                 name:@"shouldReloadAllData"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self hrpgTopHeaderNavigationController]) {
        [[self hrpgTopHeaderNavigationController] startFollowingScrollView:self.tableView];
    }
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self hrpgTopHeaderNavigationController]) {
        [[self hrpgTopHeaderNavigationController] stopFollowingScrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self hrpgTopHeaderNavigationController]) {
        [[self hrpgTopHeaderNavigationController] scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
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

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"profile"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:NSLocalizedString(@"Profile", nil)];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"authentication"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:NSLocalizedString(@"Authentication", nil)];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"apiSettings"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:NSLocalizedString(@"API", nil)];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"fixCharacterValues"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:NSLocalizedString(@"Fix Character Values", nil)];
    [section addFormRow:row];
    
    if ([user.level integerValue] > 10) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"selectClass"
                                                    rowType:XLFormRowDescriptorTypeInfo
                                                      title:nil];
        if ([user.flags.classSelected boolValue] && ![user.preferences.disableClass boolValue]) {
            row.title = NSLocalizedString(@"Change Class", nil);
            row.value = [NSString stringWithFormat:NSLocalizedString(@"%@ Gems", nil), @3];
        } else if ([user.preferences.disableClass boolValue]) {
            row.title = NSLocalizedString(@"Enable Class System", nil);
        } else if (![user.flags.classSelected boolValue]) {
            row.title = NSLocalizedString(@"Select Class", nil);
        }
        [section addFormRow:row];
    }

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"logout"
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:NSLocalizedString(@"Log Out", nil)];
    [row.cellConfig setObject:[UIColor red100] forKey:@"textLabel.textColor"];
    [section addFormRow:row];

    self.reminderSection =
        [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Reminder", nil)];
    [formDescriptor addFormSection:self.reminderSection];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"useReminder"
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:NSLocalizedString(@"Daily Reminder", nil)];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [self.reminderSection addFormRow:row];
    if ([defaults boolForKey:@"dailyReminderActive"]) {
        row.value = @YES;
        [self showDatePicker];
    }

    self.appBadgeSection =
      [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Notification Badge", nil)];
    [formDescriptor addFormSection:self.appBadgeSection];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"useAppBadge"
                                             rowType:XLFormRowDescriptorTypeBooleanSwitch
                                               title:NSLocalizedString(@"Display Notification Badge", nil)];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [self.appBadgeSection addFormRow:row];
    if ([defaults boolForKey:@"appBadgeActive"]) {
      row.value = @YES;
    }

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Day Start", nil)];
    [formDescriptor addFormSection:section];
    row =
        [XLFormRowDescriptor formRowDescriptorWithTag:@"dayStart"
                                              rowType:XLFormRowDescriptorTypeSelectorPickerView
                                                title:NSLocalizedString(@"Custom Day Start", nil)];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [section addFormRow:row];

    NSMutableArray *hourOptions = [NSMutableArray arrayWithCapacity:23];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    for (int hour = 0; hour < 24; hour++) {
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d:00:00", hour]];
        [hourOptions addObject: [XLFormOptionsObject formOptionsObjectWithValue:@(hour)
                                                                    displayText:[NSDateFormatter localizedStringFromDate:date
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

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Social", nil)];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"disablePushNotifications" rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"Disable all Push Notifications", nil)];
    row.value = [XLFormOptionsObject formOptionsOptionForValue:user.preferences.pushNotifications.unsubscribeFromAll fromOptions:nil];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [section addFormRow:row];
    self.pushNotificationRow =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"pushNotifications"
                                          rowType:XLFormRowDescriptorTypeMultipleSelector
                                            title:NSLocalizedString(@"Push Notifications", nil)];
    [self setPushNotificationSelections];
    self.pushNotificationRow.valueTransformer = [HRPGPushNotificationSettingValueTransformer class];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [section addFormRow:self.pushNotificationRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"disableInbox" rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"Disable Private Messages", nil)];
    row.value = [XLFormOptionsObject formOptionsOptionForValue:user.inboxOptOut fromOptions:nil];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [section addFormRow:row];


    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Maintenance", nil)];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"clearCache"
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:NSLocalizedString(@"Clear Cache", nil)];
    row.cellConfigAtConfigure[@"textLabel.textColor"] = [UIColor red100];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"textLabel.textColor"];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reloadContent"
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:NSLocalizedString(@"Reload Content", nil)];
    [row.cellConfig setObject:[UIColor purple400] forKey:@"textLabel.textColor"];
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
    localNotification.repeatInterval = NSCalendarUnitDay;
    localNotification.alertBody = NSLocalizedString(@"Remember to check off your Dailies!", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)setPushNotificationSelections {
    NSArray *selectorOptions = @[
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"wonChallenge"
                                                                     displayText:NSLocalizedString(@"You won a Challenge!", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"newPM"
                                                                     displayText:NSLocalizedString(@"Received Private Message", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"giftedGems"
                                                                     displayText:NSLocalizedString(@"Gifted Gems", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"giftedSubscription"
                                                                     displayText:NSLocalizedString(@"Gifted Subscription", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"invitedParty"
                                                                     displayText:NSLocalizedString(@"Invited To Party", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"invitedGuild"
                                                                     displayText:NSLocalizedString(@"Invited To Guild", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"questStarted"
                                                                     displayText:NSLocalizedString(@"Your Quest has Begun", nil)],
                                 [XLFormOptionsObject formOptionsObjectWithValue:@"invitedQuest"
                                                                     displayText:NSLocalizedString(@"Invited To Quest", nil)],
                                 ];
    self.pushNotificationRow.selectorOptions = selectorOptions;

    NSMutableArray *valueOptions = [NSMutableArray arrayWithCapacity:8];
    if ([user.preferences.pushNotifications.wonChallenge boolValue]) {
        [valueOptions addObject:selectorOptions[0]];
    }
    if ([user.preferences.pushNotifications.newPM boolValue]) {
        [valueOptions addObject:selectorOptions[1]];
    }
    if ([user.preferences.pushNotifications.giftedGems boolValue]) {
        [valueOptions addObject:selectorOptions[2]];
    }
    if ([user.preferences.pushNotifications.giftedSubscription boolValue]) {
        [valueOptions addObject:selectorOptions[3]];
    }
    if ([user.preferences.pushNotifications.invitedParty boolValue]) {
        [valueOptions addObject:selectorOptions[4]];
    }
    if ([user.preferences.pushNotifications.invitedGuild boolValue]) {
        [valueOptions addObject:selectorOptions[5]];
    }
    if ([user.preferences.pushNotifications.questStarted boolValue]) {
        [valueOptions addObject:selectorOptions[6]];
    }
    if ([user.preferences.pushNotifications.invitedQuest boolValue]) {
        [valueOptions addObject:selectorOptions[7]];
    }
    self.pushNotificationRow.value = valueOptions;
}

- (void)logoutUser {
    MRProgressOverlayView *overlayView = [MRProgressOverlayView
        showOverlayAddedTo:self.navigationController.parentViewController.view
                                          animated:YES];
    [self configureProgressView:overlayView];
    __weak HRPGSettingsViewController *weakSelf = self;
    [[HRPGManager sharedManager] logoutUser:^{
        [overlayView dismiss:YES
                  completion:^() {
                      UIStoryboard *storyboard =
                      [UIStoryboard storyboardWithName:@"Intro" bundle:nil];
                      UINavigationController *navigationController =
                      [storyboard instantiateViewControllerWithIdentifier:
                       @"LoginTableViewController"];
                      [weakSelf presentViewController:navigationController
                                             animated:YES
                                           completion:nil];
                  }];
    }];
}

- (void)resetCache {
    MRProgressOverlayView *overlayView = [MRProgressOverlayView
        showOverlayAddedTo:self.navigationController.parentViewController.view
                                          animated:YES];
    [self configureProgressView:overlayView];
    [[HRPGManager sharedManager] resetSavedDatabase:YES
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
    [self configureProgressView:overlayView];
    [[HRPGManager sharedManager] fetchContent:^() {
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

- (void)configureProgressView:(MRProgressOverlayView *)overlayView {
    [overlayView setTintColor:[UIColor purple400]];
    [overlayView setBackgroundColor:[[UIColor purple50] colorWithAlphaComponent:0.6]];
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    [super didSelectFormRow:formRow];

    if ([formRow.tag isEqual:@"profile"]) {
        [self performSegueWithIdentifier:@"ProfileSegue" sender:self];
    } else if ([formRow.tag isEqual:@"authentication"]) {
        [self performSegueWithIdentifier:@"AuthenticationSegue" sender:self];
    } else if ([formRow.tag isEqual:@"apiSettings"]) {
        [self performSegueWithIdentifier:@"APISegue" sender:self];
    } else if ([formRow.tag isEqualToString:@"selectClass"]) {
        if ([user.flags.classSelected boolValue] && ![user.preferences.disableClass boolValue]) {
            HabiticaAlertController *alertController = [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"This will reset your character's class and "
                                                                                                                                                           @"allocated points (you'll get them all back "
                                                                                                                                                           @"to re-allocate), and costs 3 gems.",
                                                                                                                                                           nil)];
            [alertController addCancelActionWithHandler:nil];
            [alertController addActionWithTitle:NSLocalizedString(@"Change Class", nil) style:UIAlertActionStyleDefault isMainAction:YES handler:^(UIButton * _Nonnull button) {
                [self displayClassSelectionViewController];
            }];
            [alertController show];
        } else {
            [self displayClassSelectionViewController];
        }
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
        } else if (![[oldValue valueData] isEqualToNumber:@(0)] &&
                   [[newValue valueData] isEqualToNumber:@(0)]) {
            [defaults setBool:NO forKey:@"dailyReminderActive"];
            [self hideDatePicker];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    } else if ([rowDescriptor.tag isEqualToString:@"useAppBadge"]) {
        [self changeAppBadgeSettings:[newValue boolValue]];
        [defaults setBool:[newValue boolValue] forKey:@"appBadgeActive"];
    } else if ([rowDescriptor.tag isEqualToString:@"reminderDate"]) {
        [self reminderTimeChanged:[rowDescriptor.value valueData]];
    } else if ([rowDescriptor.tag isEqualToString:@"dayStart"]) {
        XLFormOptionsObject *value = (XLFormOptionsObject *)newValue;
        [[HRPGManager sharedManager] changeDayStartTime:value.valueData onSuccess:nil onError:nil];
    } else if ([rowDescriptor.tag isEqualToString:@"disablePushNotifications"]) {
        self.pushNotificationRow.disabled = newValue;
        [self updateFormRow:self.pushNotificationRow];
        PushNotifications *pushNotifications = user.preferences.pushNotifications;
        pushNotifications.unsubscribeFromAll = newValue;
        [self changePushNotificationSettings:pushNotifications];
    } else if ([rowDescriptor.tag isEqualToString:@"pushNotifications"]) {
        NSArray *values = self.formValues[@"pushNotifications"];
        PushNotifications *pushNotifications = user.preferences.pushNotifications;
        NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:values.count];
        for (XLFormOptionsObject *value in values) {
            [newValues addObject:value.valueData];
        }
        for (XLFormOptionsObject *selector in self.pushNotificationRow.selectorOptions) {
            if ([newValues containsObject:selector.valueData]) {
                [pushNotifications setValue:@YES forKey:selector.valueData];
            } else {
                [pushNotifications setValue:@NO forKey:selector.valueData];
            }
        }
        [self changePushNotificationSettings:pushNotifications];
    } else if ([rowDescriptor.tag isEqualToString:@"disableInbox"]) {
        [[HRPGManager sharedManager] updateUser:@{@"inbox.optOut": newValue} onSuccess:nil onError:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == 0 && indexPath.item < 4) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return NSLocalizedString(@"Habitica defaults to check and reset your Dailies at midnight "
                                 @"in your own time zone each day. You can customize that time "
                                 @"here.",
                                 nil);
    }
    return [super tableView:tableView titleForFooterInSection:section];
}

- (void)displayClassSelectionViewController {
    UINavigationController *selectClassNavigationController = [self.storyboard
        instantiateViewControllerWithIdentifier:@"SelectClassNavigationController"];
    selectClassNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    HRPGClassTableViewController *classTableViewController =
        (HRPGClassTableViewController *)selectClassNavigationController.topViewController;
    classTableViewController.shouldResetClass = [user.flags.classSelected boolValue] || [user.preferences.disableClass boolValue];
    [self presentViewController:selectClassNavigationController animated:YES completion:^(){}];
}

- (void)changePushNotificationSettings:(PushNotifications *)newValues {
    [[HRPGManager sharedManager] updateUser:@{
                                     @"preferences.pushNotifications.giftedGems": newValues.giftedGems ? newValues.giftedGems : @NO,
                                     @"preferences.pushNotifications.giftedSubscription": newValues.giftedSubscription ? newValues.giftedSubscription : @NO,
                                     @"preferences.pushNotifications.invitedGuild": newValues.invitedGuild ? newValues.invitedGuild : @NO,
                                     @"preferences.pushNotifications.invitedParty": newValues.invitedParty ? newValues.invitedParty : @NO,
                                     @"preferences.pushNotifications.invitedQuest": newValues.invitedQuest ? newValues.invitedQuest : @NO,
                                     @"preferences.pushNotifications.newPM": newValues.newPM ? newValues.newPM : @NO,
                                     @"preferences.pushNotifications.questStarted": newValues.questStarted ? newValues.questStarted : @NO,
                                     @"preferences.pushNotifications.wonChallenge": newValues.wonChallenge ? newValues.wonChallenge : @NO,
                                     @"preferences.pushNotifications.unsubscribeFromAll": newValues.unsubscribeFromAll ? newValues.unsubscribeFromAll : @NO
                                     }onSuccess:nil onError:nil];
}

- (void)changeAppBadgeSettings:(BOOL)newValue {
    [[HRPGManager sharedManager] changeUseAppBadge: newValue];
    if (!newValue) {
      [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

@end
