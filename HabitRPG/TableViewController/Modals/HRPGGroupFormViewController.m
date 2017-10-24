//
//  HRPGCreatePartyViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 23/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGGroupFormViewController.h"
#import "Amplitude.h"
#import "XLForm.h"
#import "HRPGManager.h"
#import "Habitica-Swift.h"

@interface HRPGGroupFormViewController ()

@end

@implementation HRPGGroupFormViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
        [self initializeForm];
    }

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:@"pageview" forKey:@"hitType"];
    [eventProperties setValue:NSStringFromClass([self class]) forKey:@"page"];
    [[Amplitude instance] logEvent:@"navigate" withEventProperties:eventProperties];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.editGroup) {
        [self fillEditForm];
    }
}

- (void)initializeForm {
    XLFormDescriptor *formDescriptor =
        [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"New Party", nil)];
    formDescriptor.assignFirstResponderOnShow = YES;

    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Party"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name"
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Name", nil)];
    row.required = YES;
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"hdescription"
                                                rowType:XLFormRowDescriptorTypeTextView
                                                  title:NSLocalizedString(@"Description", nil)];
    [section addFormRow:row];

    self.form = formDescriptor;
}
- (void)fillEditForm {
    self.navigationItem.title = NSLocalizedString(@"Edit Party", nil);
    [self.form formRowWithTag:@"name"].value = self.group.name;
    [self.form formRowWithTag:@"hdescription"].value = self.group.hdescription;

    [self.tableView reloadData];
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
        if (!self.editGroup) {
            self.group =
                [NSEntityDescription insertNewObjectForEntityForName:@"Group"
                                              inManagedObjectContext:self.managedObjectContext];
            self.group.type = self.groupType;
        }
        NSDictionary *formValues = [self.form formValues];
        for (NSString *key in formValues) {
            if (formValues[key] == [NSNull null]) {
                [self.group setValue:nil forKeyPath:key];
                continue;
            }
            [self.group setValue:formValues[key] forKeyPath:key];
        }
    }
}

@end
