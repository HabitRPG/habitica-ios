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
#import "Tag.h"
#import "XLForm.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@interface HRPGFormViewController ()
@property (nonatomic) NSArray *tags;
@property (nonatomic) BOOL formFilled;
@end

@implementation HRPGFormViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        HRPGManager *sharedManager = appdelegate.sharedManager;
        self.managedObjectContext = sharedManager.getManagedObjectContext;
        [self initializeForm];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.formFilled) {
        [self fillForm];
    }
}

-(void)initializeForm {
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Task"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"text" rowType:XLFormRowDescriptorTypeText title:NSLocalizedString(@"Text", nil)];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeText title:NSLocalizedString(@"Notes", nil)];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"priority" rowType:XLFormRowDescriptorTypeSelectorPush title:NSLocalizedString(@"Difficulty", nil)];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:NSLocalizedString(@"Easy", nil)],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1.5) displayText:NSLocalizedString(@"Medium", nil)],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:NSLocalizedString(@"Hard", nil)]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:NSLocalizedString(@"Easy", nil)];
    [section addFormRow:row];
    
    self.form = formDescriptor;
}

-(void)fillForm {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    if (self.editTask) {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Edit %@", nil), self.readableTaskType];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Add %@", nil), self.readableTaskType];
    }
    
    if (![self.taskType isEqualToString:@"habit"]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"Checklist" multivaluedSection:YES];
        section.multiValuedTag = @"checklist";
        [self.form addFormSection:section];
        
        if (!self.editTask) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"checklist.new" rowType:XLFormRowDescriptorTypeText];
            [[row cellConfig] setObject:NSLocalizedString(@"Add a new tag", nil) forKey:@"textField.placeholder"];
            [section addFormRow:row];
        }
    }
    
    if ([self.taskType isEqualToString:@"habit"]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Directions", nil)];
        [self.form addFormSection:section];
        
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"up" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Up", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"down" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Down", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
    }
    
    if ([self.taskType isEqualToString:@"daily"]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Repeat", nil)];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"monday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Monday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"tuesday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Tuesday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"wednesday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Wednesday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"thursday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Thursday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"friday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Friday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"saturday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Saturday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"sunday" rowType:XLFormRowDescriptorTypeBooleanCheck title:NSLocalizedString(@"Sunday", nil)];
        row.value = [NSNumber numberWithBool:YES];
        [section addFormRow:row];
    }
    
    if ([self.taskType isEqualToString:@"todo"]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Due Date", nil)];
        [self.form addFormSection:section];
        
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Tags", nil)];
    [self.form addFormSection:section];
    [self fetchTags];
    for (Tag *tag in self.tags) {
        [section addFormRow:[XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"tag.%@", tag.id] rowType:XLFormRowDescriptorTypeBooleanCheck title:tag.name]];
    }
    
    self.formFilled = YES;
    
    if (self.editTask) {
        [self fillEditForm];
    }
}

- (void)fillEditForm {
    [self.form formRowWithTag:@"text"].value = self.task.text;
    [self.form formRowWithTag:@"notes"].value = self.task.notes;
    
    if ([self.task.priority floatValue] == 1) {
        [self.form formRowWithTag:@"priority"].value = [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority displayText:NSLocalizedString(@"Easy", nil)];
    } else if ([self.task.priority floatValue] == 1.5) {
        [self.form formRowWithTag:@"priority"].value = [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority displayText:NSLocalizedString(@"Easy", nil)];

    } else if ([self.task.priority floatValue] == 2) {
        [self.form formRowWithTag:@"priority"].value = [XLFormOptionsObject formOptionsObjectWithValue:self.task.priority displayText:NSLocalizedString(@"Hard", nil)];
    }
    
    if (![self.taskType isEqualToString:@"habit"]) {
        XLFormSectionDescriptor *section = [self.form formSectionAtIndex:1];
        if ([self.task.checklist count] == 0) {
            XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
            [[row cellConfig] setObject:NSLocalizedString(@"Add a new tag", nil) forKey:@"textField.placeholder"];
            [section addFormRow:row];
        } else {
            for (ChecklistItem *item in self.task.checklist) {
                XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:item.id rowType:XLFormRowDescriptorTypeText];
                [[row cellConfig] setObject:NSLocalizedString(@"Add a new tag", nil) forKey:@"textField.placeholder"];
                row.value = item.text;
                [section addFormRow:row];
            }
        }
    }
    
    if ([self.taskType isEqualToString:@"habit"]) {
        [self.form formRowWithTag:@"up"].value = self.task.up;
        [self.form formRowWithTag:@"down"].value = self.task.down;
    }
    
    if ([self.taskType isEqualToString:@"daily"]) {
        [self.form formRowWithTag:@"monday"].value = self.task.monday;
        [self.form formRowWithTag:@"tuesday"].value = self.task.tuesday;
        [self.form formRowWithTag:@"wednesday"].value = self.task.wednesday;
        [self.form formRowWithTag:@"thursday"].value = self.task.thursday;
        [self.form formRowWithTag:@"friday"].value = self.task.friday;
        [self.form formRowWithTag:@"saturday"].value = self.task.saturday;
        [self.form formRowWithTag:@"sunday"].value = self.task.sunday;
    }
    
    if ([self.taskType isEqualToString:@"todo"]) {
        
        
    }

    for (Tag *tag in self.task.tags) {
        [self.form formRowWithTag:[NSString stringWithFormat:@"tag.%@", tag.id]].value = [NSNumber numberWithBool:YES];
    }

    [self.tableView reloadData];
}

- (void) fetchTags {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSError *error;
    self.tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)showFormValidationError:(NSError *)error {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Validation Error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"unwindSaveSegue"]) {
        NSArray * validationErrors = [self formValidationErrors];
        if (validationErrors.count > 0){
            [self showFormValidationError:[validationErrors firstObject]];
            return NO;
        }
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    [self.tableView endEditing:YES];
    if ([segue.identifier isEqualToString:@"unwindSaveSegue"]) {
        if (!self.editTask) {
            self.task = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Task"
                         inManagedObjectContext:self.managedObjectContext];
            self.task.type = self.taskType;
        }
        NSDictionary *formValues = [self.form formValues];
        NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionary];
        for (NSString *key in formValues) {
            if ([key  hasPrefix:@"tag."]) {
                if (formValues[key] != [NSNull null]) {
                    [tagDictionary setObject:formValues[key] forKey:[key substringFromIndex:4]];
                } else {
                    [tagDictionary setObject:[NSNumber numberWithBool:NO] forKey:[key substringFromIndex:4]];
                }
                continue;
            }
            if ([key isEqualToString:@"checklist"]) {
                int checklistindex = 0;
                for (NSString *itemText in  formValues[key]) {
                    if ([itemText length] == 0) {
                        continue;
                    }
                    if ([self.task.checklist count] > checklistindex) {
                        ((ChecklistItem*)self.task.checklist[checklistindex]).text = itemText;
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
            if (formValues[key] == [NSNull null]) {
                [self.task setValue:nil forKeyPath:key];
                continue;
            }
            if ([key isEqualToString:@"priority"]) {
                XLFormOptionsObject *value = formValues[key];
                self.task.priority = value.valueData;
                continue;
            }
            [self.task setValue:formValues[key] forKeyPath:key];
        }
        self.task.tagDictionary = tagDictionary;
    }
}


@end
