//
//  HRPGInviteMembersViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 26/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGInviteMembersViewController.h"
#import "XLForm.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@interface HRPGInviteMembersViewController ()

@end

@implementation HRPGInviteMembersViewController

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

- (void) initializeForm {
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Invite Members", nil)];
    formDescriptor.assignFirstResponderOnShow = YES;
    
    self.form = formDescriptor;
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"type" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@"uuids" displayText:NSLocalizedString(@"User ID", nil)],
                            [XLFormOptionsObject formOptionsObjectWithValue:@"emails" displayText:NSLocalizedString(@"Email", nil)],
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@"emails" displayText:NSLocalizedString(@"Emails", nil)];
    row.title = NSLocalizedString(@"Invitation Type", nil);
    [section addFormRow:row];
    [formDescriptor addFormSection:section];
    
    [self initializeEmailSection];
    
}

- (void)initializeUIDSection {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:nil sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert | XLFormSectionOptionCanDelete sectionInsertMode:XLFormSectionInsertModeButton];
    section.multivaluedAddButton.title = NSLocalizedString(@"Add a User ID", nil);
    section.multivaluedTag = @"userIDs";
    // Set up row template
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:NSLocalizedString(@"Add a User ID", nil) forKey:@"textField.placeholder"];
    section.multivaluedRowTemplate = row;
    [section addFormRow:row];
    [self.form addFormSection:section];
}

- (void)initializeEmailSection {
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:nil sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert | XLFormSectionOptionCanDelete sectionInsertMode:XLFormSectionInsertModeButton];
    section.multivaluedAddButton.title = NSLocalizedString(@"Add an Email", nil);
    section.multivaluedTag = @"emails";
    // Set up row template
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:NSLocalizedString(@"Add an Email", nil) forKey:@"textField.placeholder"];
    section.multivaluedRowTemplate = row;
    [section addFormRow:row];
    [self.form addFormSection:section];
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    if ([formRow.tag isEqualToString:@"type"]) {
        [self.form removeFormSectionAtIndex:1];
        NSString *invitationType = [[self.form formValues][@"type"] valueData];
        if ([invitationType isEqualToString:@"uuids"]) {
            [self initializeUIDSection];
        } else {
            [self initializeEmailSection];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
                [members addObject:@{@"name" : @"", @"email": email}];
            }
            self.members = members;
        }
    }
}

@end
