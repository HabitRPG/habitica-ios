//
//  HRPGChoosePMRecipientViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGChoosePMRecipientViewController.h"
#import "UIColor+Habitica.h"
#import "HRPGQRCodeScannerViewController.h"
#import "NSString+UUID.h"
#import "Habitica-Swift.h"

@interface HRPGChoosePMRecipientViewController ()

@property XLFormRowDescriptor *uuidFormRow;

@end

@implementation HRPGChoosePMRecipientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XLFormDescriptor *formDescriptor =
    [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Recipient", nil)];
    formDescriptor.assignFirstResponderOnShow = YES;
    
    self.form = formDescriptor;
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    self.uuidFormRow = [XLFormRowDescriptor
           formRowDescriptorWithTag:@"userID"
           rowType:XLFormRowDescriptorTypeText];
    self.uuidFormRow.title = NSLocalizedString(@"User ID", nil);
    [self.uuidFormRow.cellConfig setObject:[UIColor purple400] forKey:@"self.tintColor"];
    [section addFormRow:self.uuidFormRow];
    [formDescriptor addFormSection:section];

    section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    row = [XLFormRowDescriptor
           formRowDescriptorWithTag:@"qrcodebutton"
           rowType:XLFormRowDescriptorTypeButton];
    row.title = NSLocalizedString(@"Scan QR Code", nil);
    [row.cellConfig setObject:[UIColor purple400] forKey:@"textLabel.textColor"];
    [section addFormRow:row];
    [formDescriptor addFormSection:section];
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    if ([formRow.tag isEqualToString:@"qrcodebutton"]) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *navController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ScanQRCodeNavController"];
        [self presentViewController:navController animated:YES completion:nil];
    }
    [self deselectFormRow:formRow];
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGQRCodeScannerViewController *scannerViewController = segue.sourceViewController;
    if (scannerViewController.scannedCode) {
        [self.uuidFormRow setValue:scannerViewController.scannedCode];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"SelectedRecipientSegue"]) {
        id userID = self.formValues[@"userID"];
        if (userID == [NSNull null] || ![userID isValidUUID]) {
            HabiticaAlertController *alertController = [HabiticaAlertController genericErrorWithMessage:NSLocalizedString(@"You have to specify a valid Habitica User ID as recipient.", nil) title:NSLocalizedString(@"Invalid Habitica User ID", nil)];
            [alertController show];
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectedRecipientSegue"]) {
        self.userID = self.formValues[@"userID"];
    }
}


@end
