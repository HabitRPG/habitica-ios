//
//  HRPGAddViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFormViewController.h"
#import "ChecklistItem.h"

#import "NSString+Emoji.h"
#import "Reminder.h"
#import "Tag.h"
#import "Habitica-Swift.h"

@interface HRPGFormViewController ()
@property(nonatomic) NSArray *tags;
@property(nonatomic) BOOL formFilled;
@property(nonatomic) XLFormSectionDescriptor *duedateSection;
@property NSInteger customDayStart;
@property TaskRepeatablesSummaryInteractor *summaryInteractor;

@end

@implementation HRPGFormViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        User *user = [[HRPGManager sharedManager] getUser];
        self.customDayStart = [user.preferences.dayStart integerValue];
        self.managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
        [self initializeForm];
        self.summaryInteractor = [[TaskRepeatablesSummaryInteractor alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.formFilled) {
        [self fillForm];
    }
}

- (void)initializeForm {
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New"];

    formDescriptor.assignFirstResponderOnShow = YES;

    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Task"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"text"
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Text", nil)];
    row.required = YES;
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes"
                                                rowType:XLFormRowDescriptorTypeTextView
                                                  title:NSLocalizedString(@"Notes", nil)];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"priority"
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:NSLocalizedString(@"Difficulty", nil)];
    row.selectorOptions = @[
        [XLFormOptionsObject formOptionsObjectWithValue:@(0.1)
                                            displayText:NSLocalizedString(@"Trivial", nil)],
        [XLFormOptionsObject formOptionsObjectWithValue:@(1)
                                            displayText:NSLocalizedString(@"Easy", nil)],
        [XLFormOptionsObject formOptionsObjectWithValue:@(1.5)
                                            displayText:NSLocalizedString(@"Medium", nil)],
        [XLFormOptionsObject formOptionsObjectWithValue:@(2)
                                            displayText:NSLocalizedString(@"Hard", nil)]
    ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1)
                                                    displayText:NSLocalizedString(@"Easy", nil)];
    row.required = YES;
    row.selectorTitle = NSLocalizedString(@"Select Difficulty", nil);
    [section addFormRow:row];

    if ([self hasTaskBasedAllocation]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"attribute"
                                                    rowType:XLFormRowDescriptorTypeSelectorPush
                                                      title:NSLocalizedString(@"Attributes", nil)];
        row.selectorOptions = @[
            [XLFormOptionsObject formOptionsObjectWithValue:@"str"
                                                displayText:NSLocalizedString(@"Strength", nil)],
            [XLFormOptionsObject formOptionsObjectWithValue:@"int"
                                                displayText:NSLocalizedString(@"Intelligence", nil)],
            [XLFormOptionsObject formOptionsObjectWithValue:@"con"
                                                displayText:NSLocalizedString(@"Constitution", nil)],
            [XLFormOptionsObject formOptionsObjectWithValue:@"per"
                                                displayText:NSLocalizedString(@"Perception", nil)]
        ];
        row.value =
            [XLFormOptionsObject formOptionsObjectWithValue:@"str"
                                                displayText:NSLocalizedString(@"Strength", nil)];
        row.required = YES;
        row.selectorTitle = NSLocalizedString(@"Select Attributes", nil);
        [section addFormRow:row];
    }

    self.form = formDescriptor;
}

- (void)fillForm {
    if (self.formFilled) {
        return;
    }
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    if (self.editTask) {
        self.navigationItem.title =
            [NSString stringWithFormat:NSLocalizedString(@"Edit %@", nil), self.readableTaskType];
    } else {
        self.navigationItem.title =
            [NSString stringWithFormat:NSLocalizedString(@"Add %@", nil), self.readableTaskType];
    }

    if (![self.taskType isEqualToString:@"habit"]) {
        section = [XLFormSectionDescriptor
            formSectionWithTitle:@"Checklist"
                  sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert |
                                 XLFormSectionOptionCanDelete
               sectionInsertMode:XLFormSectionInsertModeButton];
        section.multivaluedAddButton.title = NSLocalizedString(@"Add a new checklist item", nil);
        section.multivaluedTag = @"checklist";
        // Set up row template
        row =
            [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
        [row cellConfig][@"textField.placeholder"] =
            NSLocalizedString(@"Add a new checklist item", nil);
        section.multivaluedRowTemplate = row;
        [self.form addFormSection:section];
    }

    if ([self.taskType isEqualToString:@"habit"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"frequency" rowType:XLFormRowDescriptorTypeSelectorPush title:NSLocalizedString(@"Counter resets every", nil)];
        row.selectorOptions = @[
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"daily"
                                 displayText:NSLocalizedString(@"Day", nil)],
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"weekly"
                                 displayText:NSLocalizedString(@"Week", nil)],
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"monthly"
                                 displayText:NSLocalizedString(@"Month", nil)]
                                ];
        row.value =
        [XLFormOptionsObject formOptionsObjectWithValue:@"weekly"
                                            displayText:NSLocalizedString(@"Week", nil)];
        row.required = YES;
        section = [self.form formSectionAtIndex:0];
        [section addFormRow:row];
        
        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Actions", nil)];
        [self.form addFormSection:section];

        row =
            [XLFormRowDescriptor formRowDescriptorWithTag:@"up"
                                                  rowType:XLFormRowDescriptorTypeBooleanCheck
                                                    title:NSLocalizedString(@"Positive (+)", nil)];
        row.value = @YES;
        [section addFormRow:row];

        row =
            [XLFormRowDescriptor formRowDescriptorWithTag:@"down"
                                                  rowType:XLFormRowDescriptorTypeBooleanCheck
                                                    title:NSLocalizedString(@"Negative (-)", nil)];
        row.value = @YES;
        [section addFormRow:row];
    }
    NSString *rowType;
    if ([self.taskType isEqualToString:@"daily"]) {
        section = [self.form formSectionAtIndex:0];
        XLFormRowDescriptor *row =
            [XLFormRowDescriptor formRowDescriptorWithTag:@"startDate"
                                                  rowType:XLFormRowDescriptorTypeDateInline
                                                    title:@"Start Date"];
        NSDate *date = [NSDate new];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour) fromDate:date];
        if (components.hour < self.customDayStart) {
            [components setHour:-24];
            date = [calendar dateByAddingComponents:components toDate:date options:0];
        }
        row.value = date;
        [section addFormRow:row];

        section = [XLFormSectionDescriptor formSectionWithTitle:@""];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"frequency"
                                                    rowType:XLFormRowDescriptorTypeSelectorPush
                                                      title:NSLocalizedString(@"Frequency", nil)];
        row.selectorOptions = @[
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"daily"
                                 displayText:NSLocalizedString(@"Daily", nil)],
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"weekly"
                                 displayText:NSLocalizedString(@"Weekly", nil)],
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"monthly"
                                 displayText:NSLocalizedString(@"Monthly", nil)],
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"yearly"
                                 displayText:NSLocalizedString(@"Yearly", nil)]
                                ];
        row.value =
        [XLFormOptionsObject formOptionsObjectWithValue:@"weekly"
                                            displayText:NSLocalizedString(@"Weekly", nil)];
        row.required = YES;
        row.selectorTitle = NSLocalizedString(@"Select Frequency", nil);
        [section addFormRow:row];
        
        row = [XLFormRowDescriptor
               formRowDescriptorWithTag:@"everyX"
               rowType:XLFormRowDescriptorTypeStepCounter
               title:NSLocalizedString(@"Repeat every", nil)];
        [section addFormRow:row];
        [self setFrequencyRows:@"weekly" fromOldValue:nil];

        rowType = XLFormRowDescriptorTypeTime;
    }

    if ([self.taskType isEqualToString:@"todo"]) {
        self.duedateSection =
            [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Due Date", nil)];
        row = [XLFormRowDescriptor
            formRowDescriptorWithTag:@"hasDueDate"
                             rowType:XLFormRowDescriptorTypeBooleanCheck
                               title:NSLocalizedString(@"Has a due date", nil)];
        row.value = @NO;
        [self.duedateSection addFormRow:row];
        [self.form addFormSection:self.duedateSection];

        rowType = XLFormRowDescriptorTypeDateTime;
    }

    if (![self.taskType isEqualToString:@"habit"] && rowType != nil) {
        section = [XLFormSectionDescriptor
            formSectionWithTitle:NSLocalizedString(@"Reminders", nil)
                  sectionOptions:XLFormSectionOptionCanInsert | XLFormSectionOptionCanDelete
               sectionInsertMode:XLFormSectionInsertModeButton];
        section.multivaluedAddButton.title = NSLocalizedString(@"Add a new reminder", nil);
        section.multivaluedTag = @"reminders";
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reminder" rowType:rowType title:@""];
        section.multivaluedRowTemplate = row;
    }

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Tags", nil)];
    [self.form addFormSection:section];
    [self fetchTags];
    for (Tag *tag in self.tags) {
        row = [XLFormRowDescriptor
            formRowDescriptorWithTag:[NSString stringWithFormat:@"tag.%@", tag.id]
                             rowType:XLFormRowDescriptorTypeBooleanCheck
                               title:tag.name];
        row.value = @([self.activeTags containsObject:tag]);
        [section addFormRow:row];
    }

    self.formFilled = YES;
}

- (void)fillEditForm {
    if (!self.formFilled) {
        [self fillForm];
    }
    [self.form formRowWithTag:@"text"].value =
        [self.task.text stringByReplacingEmojiCheatCodesWithUnicode];
    [self.form formRowWithTag:@"notes"].value =
        [self.task.notes stringByReplacingEmojiCheatCodesWithUnicode];

    if ([self.task.priority floatValue] == 0.1f) {
        [self.form formRowWithTag:@"priority"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority
                                                displayText:NSLocalizedString(@"Trivial", nil)];
    } else if ([self.task.priority floatValue] == 1) {
        [self.form formRowWithTag:@"priority"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority
                                                displayText:NSLocalizedString(@"Easy", nil)];
    } else if ([self.task.priority floatValue] == 1.5f) {
        [self.form formRowWithTag:@"priority"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority
                                                displayText:NSLocalizedString(@"Medium", nil)];
    } else if ([self.task.priority floatValue] == 2) {
        [self.form formRowWithTag:@"priority"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority
                                                displayText:NSLocalizedString(@"Hard", nil)];
    }

    if ([self.task.attribute isEqualToString:@"str"]) {
        [self.form formRowWithTag:@"attribute"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.attribute
                                                displayText:NSLocalizedString(@"Strength", nil)];
    } else if ([self.task.attribute isEqualToString:@"int"]) {
        [self.form formRowWithTag:@"attribute"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.attribute
                                                displayText:NSLocalizedString(@"Intelligence", nil)];
    } else if ([self.task.attribute isEqualToString:@"con"]) {
        [self.form formRowWithTag:@"attribute"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.attribute
                                                displayText:NSLocalizedString(@"Constitution", nil)];
    } else if ([self.task.attribute isEqualToString:@"per"]) {
        [self.form formRowWithTag:@"attribute"].value =
            [XLFormOptionsObject formOptionsObjectWithValue:self.task.attribute
                                                displayText:NSLocalizedString(@"Perception", nil)];
    }

    if (![self.taskType isEqualToString:@"habit"]) {
        XLFormSectionDescriptor *section = [self.form formSectionAtIndex:1];

        for (ChecklistItem *item in self.task.checklist) {
            XLFormRowDescriptor *row =
                [XLFormRowDescriptor formRowDescriptorWithTag:item.id
                                                      rowType:XLFormRowDescriptorTypeText];
            [row cellConfig][@"textField.placeholder"] =
                NSLocalizedString(@"Add a new checklist item", nil);
            row.value = item.text;
            [section addFormRow:row];
        }

        NSString *rowType;
        if ([self.task.type isEqualToString:@"daily"]) {
            rowType = XLFormRowDescriptorTypeTime;
        } else {
            rowType = XLFormRowDescriptorTypeDateTime;
        }

        section = [self.form formSectionAtIndex:3];
        for (Reminder *item in self.task.reminders) {
            XLFormRowDescriptor *row =
                [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:rowType title:@""];
            row.value = item.time;
            [section addFormRow:row];
        }
    }

    if ([self.taskType isEqualToString:@"habit"]) {
        [self.form formRowWithTag:@"up"].value = self.task.up;
        [self.form formRowWithTag:@"down"].value = self.task.down;
        [self.form formRowWithTag:@"frequency"].value = self.task.frequency;
    }

    if ([self.taskType isEqualToString:@"daily"]) {
        [self.form formRowWithTag:@"startDate"].value = self.task.startDate;
        [self.form formRowWithTag:@"frequency"].value = self.task.frequency;
        [self.form formRowWithTag:@"everyX"].value = self.task.everyX;
    }

    if ([self.taskType isEqualToString:@"todo"]) {
        if (self.task.duedate) {
            [self.form formRowWithTag:@"hasDueDate"].value = @YES;
            [self.form formRowWithTag:@"duedate"].value = self.task.duedate;
        }
    }

    for (Tag *tag in self.task.tags) {
        [self.form formRowWithTag:[NSString stringWithFormat:@"tag.%@", tag.id]].value = @YES;
    }

    [self.tableView reloadData];
}

- (void)setOldDailyOptions {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [self.form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"frequency"
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:NSLocalizedString(@"Frequency", nil)];
    row.selectorOptions = @[
                            [XLFormOptionsObject
                             formOptionsObjectWithValue:@"daily"
                             displayText:NSLocalizedString(@"Every x days", nil)],
                            [XLFormOptionsObject
                             formOptionsObjectWithValue:@"weekly"
                             displayText:NSLocalizedString(@"On certain days of the week", nil)]
                            ];
    row.value =
    [XLFormOptionsObject formOptionsObjectWithValue:@"weekly"
                                        displayText:NSLocalizedString(@"Weekly", nil)];
    row.required = YES;
    row.selectorTitle = NSLocalizedString(@"Select Frequency", nil);
    [section addFormRow:row];
    if (!self.editTask) {
        [self setOldFrequencyRows:@"weekly"];
    }
}

- (void)fetchTags {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSError *error;
    self.tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)showFormValidationError:(NSError *)error {
    HabiticaAlertController *alertController = [HabiticaAlertController genericErrorWithMessage:nil title:NSLocalizedString(@"Validation Error", nil)];
    [alertController show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"unwindSaveSegue"]) {
        NSArray *validationErrors = [self formValidationErrors];
        if (validationErrors.count > 0) {
            [self showFormValidationError:[validationErrors firstObject]];
            return NO;
        }
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    [self.tableView endEditing:YES];
    if ([segue.identifier isEqualToString:@"unwindSaveSegue"]) {
        NSError *error;
        if (!self.editTask ||
            (self.editTask &&
             [self.task.managedObjectContext existingObjectWithID:self.task.objectID
                                                            error:&error] == nil)) {
            self.task =
                [NSEntityDescription insertNewObjectForEntityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
            self.task.type = self.taskType;
        }
        NSDictionary *formValues = [self.form formValues];
        NSMutableArray *tagArray = [NSMutableArray array];
        for (NSString *key in formValues) {
            if ([key isEqualToString:@"hasDueDate"]) {
                if (![formValues[key] boolValue]) {
                    self.task.duedate = nil;
                }
                continue;
            }
            if ([key isEqualToString:@"frequency"]) {
                self.task.frequency = [formValues[key] valueData];
                continue;
            }
            if ([key hasPrefix:@"tag."]) {
                if (formValues[key] != [NSNull null]) {
                    if ([formValues[key] boolValue]) {
                        [tagArray addObject:[key substringFromIndex:4]];
                    }
                }
                continue;
            }
            if ([key isEqualToString:@"checklist"]) {
                int checklistindex = 0;
                for (NSString *itemText in formValues[key]) {
                    if ([itemText length] == 0) {
                        continue;
                    }
                    if ([self.task.checklist count] > checklistindex) {
                        ((ChecklistItem *)self.task.checklist[checklistindex]).text = itemText;
                    } else {
                        ChecklistItem *newItem = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ChecklistItem"
                                     inManagedObjectContext:self.managedObjectContext];
                        newItem.text = itemText;
                        [self.task addChecklistObject:newItem];
                    }
                    checklistindex++;
                }
                while ([self.task.checklist count] > checklistindex) {
                    [self.task removeChecklistObject:self.task.checklist[checklistindex]];
                }
                continue;
            }
            if ([key isEqualToString:@"reminders"]) {
                int reminderindex = 0;
                for (NSDate *itemTime in formValues[key]) {
                    if ([self.task.reminders count] > reminderindex) {
                        ((Reminder *)self.task.reminders[reminderindex]).time = itemTime;
                    } else {
                        Reminder *newItem = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Reminder"
                                     inManagedObjectContext:self.managedObjectContext];
                        newItem.time = itemTime;
                        newItem.id = [[NSUUID UUID] UUIDString];
                        [self.task addRemindersObject:newItem];
                    }
                    reminderindex++;
                }
                while ([self.task.reminders count] > reminderindex) {
                    [self.task removeRemindersObject:self.task.reminders[reminderindex]];
                }
                continue;
            }
            if (formValues[key] == [NSNull null]) {
                if ([key isEqualToString:@"text"] || [key isEqualToString:@"notes"]) {
                    [self.task setValue:@"" forKeyPath:key];
                } else {
                    [self.task setValue:nil forKeyPath:key];
                }
                continue;
            }
            if ([key isEqualToString:@"priority"]) {
                XLFormOptionsObject *value = formValues[key];
                self.task.priority = value.valueData;
                continue;
            }
            if ([key isEqualToString:@"attribute"]) {
                XLFormOptionsObject *value = formValues[key];
                self.task.attribute = value.valueData;
                continue;
            }
            if ([key isEqualToString:@"repeatsOn"]) {
                XLFormOptionsObject *value = formValues[key];
                NSDate *startDate = ((XLFormOptionsObject *)formValues[@"startDate"]).valueData;
                if (startDate == nil) {
                    startDate = [NSDate date];
                }
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth fromDate:startDate];
                NSMutableSet *daysOfMonth = [[NSMutableSet alloc] init];
                NSMutableSet *weeksOfMonth = [[NSMutableSet alloc] init];
                if ([value.valueData isEqualToString:@"daysOfMonth"]) {
                    [daysOfMonth addObject:@(components.day)];
                } else {
                    [weeksOfMonth addObject:@(components.weekOfMonth)];
                }
                self.task.daysOfMonth = daysOfMonth;
                self.task.weeksOfMonth = weeksOfMonth;
                continue;
            }
            [self.task setValue:formValues[key] forKeyPath:key];
        }
        self.task.tagArray = tagArray;
    }
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow
                                oldValue:(id)oldValue
                                newValue:(id)newValue {
    if ([formRow.tag isEqualToString:@"hasDueDate"]) {
        NSNumber *value = formRow.value;
        if ([value boolValue]) {
            XLFormRowDescriptor *row =
                [XLFormRowDescriptor formRowDescriptorWithTag:@"duedate"
                                                      rowType:XLFormRowDescriptorTypeDateInline
                                                        title:@"Date"];
            row.value = [NSDate new];
            [self.duedateSection addFormRow:row];
        } else {
            [self.form removeFormRowWithTag:@"duedate"];
        }
    } else if ([formRow.tag isEqualToString:@"frequency"]) {
        if ([[oldValue class] isSubclassOfClass:[XLFormOptionsObject class]]) {
            [self setFrequencyRows:[formRow.value valueData] fromOldValue:((XLFormOptionsObject *)oldValue).formValue];
        } else {
            [self setFrequencyRows:[formRow.value valueData] fromOldValue:oldValue];
        }
    }
    if (![formRow.tag isEqualToString:@"reminder"] && formRow.tag != nil) {
        [self.tableView beginUpdates];
        [self.tableView footerViewForSection:2].textLabel.text = [self tableView:self.tableView titleForFooterInSection:2];
        [[self.tableView footerViewForSection:2].textLabel sizeThatFits:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)];
        [self.tableView endUpdates];
    }
}

- (void)formRowHasBeenAdded:(XLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath {
    if ([self.taskType isEqualToString:@"daily"]) {
        if (indexPath.section == 3 && formRow.value == nil) {
            formRow.value = [NSDate date];
        }
    }
    [super formRowHasBeenAdded:formRow atIndexPath:indexPath];
}

- (void)setFrequencyRows:(NSString *)frequencyType fromOldValue:(NSString *)oldFrequencyType {
    if ([frequencyType isEqualToString:oldFrequencyType] || [self.taskType isEqualToString:@"habit"]) {
        return;
    }
    XLFormSectionDescriptor *section = [self.form formSectionAtIndex:2];
    if ([oldFrequencyType isEqualToString:@"weekly"]) {
        [section removeFormRowAtIndex:7];
        [section removeFormRowAtIndex:7];
        [section removeFormRowAtIndex:6];
        [section removeFormRowAtIndex:5];
        [section removeFormRowAtIndex:4];
        [section removeFormRowAtIndex:3];
        [section removeFormRowAtIndex:2];
    } else if ([oldFrequencyType isEqualToString:@"monthly"]) {
        [section removeFormRowAtIndex:2];
    }
    
    if ([frequencyType isEqualToString:@"weekly"]) {
        XLFormRowDescriptor *row =
        [XLFormRowDescriptor formRowDescriptorWithTag:@"monday"
                                              rowType:XLFormRowDescriptorTypeBooleanCheck
                                                title:NSLocalizedString(@"Monday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"tuesday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Tuesday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"wednesday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Wednesday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"thursday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Thursday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"friday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Friday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"saturday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Saturday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"sunday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Sunday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        if (self.editTask) {
            [self.form formRowWithTag:@"monday"].value = self.task.monday;
            [self.form formRowWithTag:@"tuesday"].value = self.task.tuesday;
            [self.form formRowWithTag:@"wednesday"].value = self.task.wednesday;
            [self.form formRowWithTag:@"thursday"].value = self.task.thursday;
            [self.form formRowWithTag:@"friday"].value = self.task.friday;
            [self.form formRowWithTag:@"saturday"].value = self.task.saturday;
            [self.form formRowWithTag:@"sunday"].value = self.task.sunday;
        }
    } else if ([frequencyType isEqualToString:@"monthly"]) {
        XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:@"repeatsOn"
                                                    rowType:XLFormRowDescriptorTypeSelectorPush
                                                      title:NSLocalizedString(@"RepeatsOn", nil)];
        row.selectorOptions = @[
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"daysOfMonth"
                                 displayText:NSLocalizedString(@"Day of the Month", nil)],
                                [XLFormOptionsObject
                                 formOptionsObjectWithValue:@"weeksOfMonth"
                                 displayText:NSLocalizedString(@"Week of the Month", nil)]
                                ];
        row.required = YES;
        row.selectorTitle = NSLocalizedString(@"Repeats On", nil);
        if (self.editTask) {
            if (self.task.weeksOfMonth.count > 0) {
                row.value =
                [XLFormOptionsObject formOptionsObjectWithValue:@"weeksOfMonth"
                                                    displayText:NSLocalizedString(@"Week of the Month", nil)];
            } else {
                row.value =
                [XLFormOptionsObject formOptionsObjectWithValue:@"daysOfMonth"
                                                    displayText:NSLocalizedString(@"Day of the Month", nil)];
            }
        } else{
            row.value =
            [XLFormOptionsObject formOptionsObjectWithValue:@"daysOfMonth"
                                                displayText:NSLocalizedString(@"Day of the Month", nil)];
        }
        [section addFormRow:row];
    }
}

- (void)setOldFrequencyRows:(NSString *)frequencyType {
    XLFormSectionDescriptor *section = [self.form formSectionAtIndex:2];
    if (![frequencyType isEqualToString:@"weekly"]) {
        if (section.formRows.count > 3) {
            [section removeFormRowAtIndex:7];
            [section removeFormRowAtIndex:6];
            [section removeFormRowAtIndex:5];
            [section removeFormRowAtIndex:4];
            [section removeFormRowAtIndex:3];
            [section removeFormRowAtIndex:2];
            [section removeFormRowAtIndex:1];
        }
        XLFormRowDescriptor *row;
        if (section.formRows.count == 1) {
            row = [XLFormRowDescriptor
                   formRowDescriptorWithTag:@"everyX"
                   rowType:XLFormRowDescriptorTypeInteger
                   title:NSLocalizedString(@"Repeat every X days", nil)];
            [section addFormRow:row];
        } else {
            row = section.formRows[1];
        }
        if (self.editTask) {
            row.value = self.task.everyX;
        } else {
            row.value = @1;
        }
        row.required = YES;
    } else {
        if (section.formRows.count > 1) {
            [section removeFormRowAtIndex:1];
        }

        XLFormRowDescriptor *row =
            [XLFormRowDescriptor formRowDescriptorWithTag:@"monday"
                                                  rowType:XLFormRowDescriptorTypeBooleanCheck
                                                    title:NSLocalizedString(@"Monday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"tuesday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Tuesday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"wednesday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Wednesday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"thursday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Thursday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"friday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Friday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"saturday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Saturday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"sunday"
                                                    rowType:XLFormRowDescriptorTypeBooleanCheck
                                                      title:NSLocalizedString(@"Sunday", nil)];
        row.value = @YES;
        [section addFormRow:row];
        if (self.editTask) {
            [self.form formRowWithTag:@"monday"].value = self.task.monday;
            [self.form formRowWithTag:@"tuesday"].value = self.task.tuesday;
            [self.form formRowWithTag:@"wednesday"].value = self.task.wednesday;
            [self.form formRowWithTag:@"thursday"].value = self.task.thursday;
            [self.form formRowWithTag:@"friday"].value = self.task.friday;
            [self.form formRowWithTag:@"saturday"].value = self.task.saturday;
            [self.form formRowWithTag:@"sunday"].value = self.task.sunday;
        }
    }
}

- (void)setTaskType:(NSString *)taskType {
    _taskType = taskType;
    [self initializeForm];
}

- (void)setEditTask:(BOOL)editTask {
    _editTask = editTask;
    [self fillEditForm];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.taskType isEqualToString:@"daily"]) {
        if (section == 2) {
            NSDictionary<NSString *, XLFormOptionsObject *> *values = [self.form formValues];
            
            NSDate *startDate = ((XLFormOptionsObject *)values[@"startDate"]).valueData;
            if (startDate == nil) {
                startDate = [NSDate date];
            }
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth fromDate:startDate];
            NSMutableSet *daysOfMonth = [[NSMutableSet alloc] init];
            NSMutableSet *weeksOfMonth = [[NSMutableSet alloc] init];
            if ([values[@"repeatsOn"].valueData isEqualToString:@"daysOfMonth"]) {
                [daysOfMonth addObject:[NSNumber numberWithInteger:components.day]];
            } else {
                [weeksOfMonth addObject:[NSNumber numberWithInteger:components.weekOfMonth]];
            }
            return [self.summaryInteractor repeatablesSummaryWithFrequency:values[@"frequency"].valueData everyX:values[@"everyX"].valueData monday:values[@"monday"].valueData tuesday:values[@"tuesday"].valueData wednesday:values[@"wednesday"].valueData thursday:values[@"thursday"].valueData friday:values[@"friday"].valueData saturday:values[@"saturday"].valueData sunday:values[@"sunday"].valueData startDate:values[@"startDate"].valueData daysOfMonth:daysOfMonth weeksOfMonth:weeksOfMonth];
        }
        if (section == 3) {
            return NSLocalizedString(@"Each reminder notifies on the days the daily is active.", nil);
        }
    }
    return nil;
}

- (BOOL)hasTaskBasedAllocation {
    User *user = [[HRPGManager sharedManager] getUser];
    return [user.preferences.automaticAllocation boolValue] && [user.preferences.allocationMode isEqualToString:@"taskbased"];
}

@end
