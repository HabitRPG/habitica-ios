//
//  HRPGInviteMembersViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 26/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGInviteMembersViewController.h"
#import "Amplitude.h"
#import "XLForm.h"
#import "HRPGQRCodeScannerViewController.h"
#import "UIColor+Habitica.h"

@interface HRPGInviteMembersViewController ()

@property XLFormSectionDescriptor *uuidSection;

@end

@implementation HRPGInviteMembersViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
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

- (void)initializeForm {
    XLFormDescriptor *formDescriptor =
        [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Invite Members", nil)];
    formDescriptor.assignFirstResponderOnShow = YES;

    self.form = formDescriptor;

    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    row = [XLFormRowDescriptor
        formRowDescriptorWithTag:@"type"
                         rowType:XLFormRowDescriptorTypeSelectorSegmentedControl];
    row.selectorOptions = @[
        [XLFormOptionsObject formOptionsObjectWithValue:@"uuids"
                                            displayText:NSLocalizedString(@"User ID", nil)],
        [XLFormOptionsObject formOptionsObjectWithValue:@"emails"
                                            displayText:NSLocalizedString(@"Email", nil)],
    ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@"emails"
                                                    displayText:NSLocalizedString(@"Emails", nil)];
    row.title = NSLocalizedString(@"Invitation Type", nil);
    [row.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [section addFormRow:row];
    [formDescriptor addFormSection:section];

    [self initializeEmailSection];
}

- (void)initializeUIDSection {
    XLFormRowDescriptor *row;

    self.uuidSection = [XLFormSectionDescriptor
        formSectionWithTitle:nil
              sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert |
                             XLFormSectionOptionCanDelete
           sectionInsertMode:XLFormSectionInsertModeButton];
    self.uuidSection.multivaluedAddButton.title = NSLocalizedString(@"Add a User ID", nil);
    self.uuidSection.multivaluedTag = @"userIDs";
    // Set up row template
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
    [row cellConfig][@"textField.placeholder"] = NSLocalizedString(@"Add a User ID", nil);
    [row.cellConfig setObject:[UIColor purple400] forKey:@"textLabel.textColor"];
    self.uuidSection.multivaluedRowTemplate = row;
    [self.uuidSection addFormRow:row];
    [self.form addFormSection:self.uuidSection];
    
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"qrcodebutton" rowType:XLFormRowDescriptorTypeButton];
    row.title = NSLocalizedString(@"Scan QR Code", nil);
    [row.cellConfig setObject:[UIColor purple400] forKey:@"textLabel.textColor"];
    [section addFormRow:row];
    [self.form addFormSection:section];
}

- (void)initializeEmailSection {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    section = [XLFormSectionDescriptor
        formSectionWithTitle:nil
              sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert |
                             XLFormSectionOptionCanDelete
           sectionInsertMode:XLFormSectionInsertModeButton];
    section.multivaluedAddButton.title = NSLocalizedString(@"Add an Email", nil);
    section.multivaluedTag = @"emails";
    // Set up row template
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
    [row cellConfig][@"textField.placeholder"] = NSLocalizedString(@"Add an Email", nil);
    section.multivaluedRowTemplate = row;
    [section addFormRow:row];
    [self.form addFormSection:section];
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    if ([formRow.tag isEqualToString:@"qrcodebutton"]) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *navController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ScanQRCodeNavController"];
        [self presentViewController:navController animated:YES completion:nil];
    }
    [self deselectFormRow:formRow];
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow
                                oldValue:(id)oldValue
                                newValue:(id)newValue {
    if ([formRow.tag isEqualToString:@"type"]) {
        if (self.form.formSections.count == 3) {
            [self.form removeFormSectionAtIndex:2];
        }
        [self.form removeFormSectionAtIndex:1];
        NSString *invitationType = [[self.form formValues][@"type"] valueData];
        if ([invitationType isEqualToString:@"uuids"]) {
            [self initializeUIDSection];
        } else {
            [self initializeEmailSection];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    [self.tableView endEditing:YES];
    if ([segue.identifier isEqualToString:@"unwindSaveSegue"]) {
        self.invitationType = [[self.form formValues][@"type"] valueData];
        if ([self.invitationType isEqualToString:@"uuids"]) {
            self.members = [self.form formValues][@"userIDs"];
        } else {
            NSArray *memberEmails = [self.form formValues][@"emails"];
            NSMutableArray *members = [NSMutableArray arrayWithCapacity:memberEmails.count];
            for (NSString *email in memberEmails) {
                [members addObject:@{ @"name" : @"", @"email" : email }];
            }
            self.members = members;
        }
    }
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGQRCodeScannerViewController *scannerViewController = segue.sourceViewController;
    if (scannerViewController.scannedCode) {
        XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText title:nil];
        [row cellConfig][@"textField.placeholder"] = NSLocalizedString(@"Add a User ID", nil);
        row.value = scannerViewController.scannedCode;
        [self.uuidSection addFormRow:row];
    }
}

@end
