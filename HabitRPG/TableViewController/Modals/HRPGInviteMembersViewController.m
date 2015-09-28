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
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"User IDs" sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert | XLFormSectionOptionCanDelete sectionInsertMode:XLFormSectionInsertModeButton];
    section.multivaluedAddButton.title = NSLocalizedString(@"Add a User ID", nil);
    section.multivaluedTag = @"userIDs";
    // Set up row template
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:NSLocalizedString(@"Add a User ID", nil) forKey:@"textField.placeholder"];
    section.multivaluedRowTemplate = row;
    [section addFormRow:row];
    [formDescriptor addFormSection:section];
    
    self.form = formDescriptor;
    
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    [self.tableView endEditing:YES];
    if ([segue.identifier isEqualToString:@"unwindSaveSegue"]) {
        self.members = [self.form formValues][@"userIDs"];
    }
}

@end
