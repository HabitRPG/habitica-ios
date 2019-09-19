//
//  HRPGChoosePMRecipientViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGChoosePMRecipientViewController.h"
#import "Habitica-Swift.h"

@interface HRPGChoosePMRecipientViewController ()

@property XLFormRowDescriptor *usernameFormRow;

@end

@implementation HRPGChoosePMRecipientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = objcL10n.titleChooseRecipient;
    
    XLFormDescriptor *formDescriptor =
    [XLFormDescriptor formDescriptorWithTitle:objcL10n.recipient];
    formDescriptor.assignFirstResponderOnShow = YES;
    
    self.form = formDescriptor;
    
    XLFormSectionDescriptor *section;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    self.usernameFormRow = [XLFormRowDescriptor
           formRowDescriptorWithTag:@"username"
           rowType:XLFormRowDescriptorTypeText];
    self.usernameFormRow.title = objcL10n.username;
    [self.usernameFormRow.cellConfig setObject:[ObjcThemeWrapper tintColor] forKey:@"self.tintColor"];
    [section addFormRow:self.usernameFormRow];
    [formDescriptor addFormSection:section];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"SelectedRecipientSegue"]) {
        id username = self.formValues[@"username"];
        if (username == [NSNull null]) {
            HabiticaAlertController *alertController = [HabiticaAlertController genericErrorWithMessage:objcL10n.invalidRecipientMessage title:objcL10n.invalidRecipientTitle];
            [alertController show];
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectedRecipientSegue"]) {
        self.username = self.formValues[@"username"];
    }
}


@end
