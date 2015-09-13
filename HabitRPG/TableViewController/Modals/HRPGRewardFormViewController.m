//
//  HRPG.m
//  Habitica
//
//  Created by Phillip Thelen on 21/04/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGRewardFormViewController.h"
#import "ChecklistItem.h"
#import "NSString+Emoji.h"
#import "Tag.h"
#import "XLForm.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@interface HRPGRewardFormViewController ()
@property (nonatomic) NSArray *tags;
@end

@implementation HRPGRewardFormViewController

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
    if (self.editReward) {
        [self fillEditForm];
    }
}

-(void)initializeForm {
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"New Reward", nil)];
    formDescriptor.assignFirstResponderOnShow = YES;
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Reward"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"text" rowType:XLFormRowDescriptorTypeText title:NSLocalizedString(@"Text", nil)];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeTextView title:NSLocalizedString(@"Notes", nil)];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"value" rowType:XLFormRowDescriptorTypeNumber title:NSLocalizedString(@"Value", nil)];
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Tags", nil)];
    [formDescriptor addFormSection:section];
    [self fetchTags];
    for (Tag *tag in self.tags) {
        [section addFormRow:[XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"tag.%@", tag.id] rowType:XLFormRowDescriptorTypeBooleanCheck title:tag.name]];
    }
    
    self.form = formDescriptor;
}
- (void)fillEditForm {
    self.navigationItem.title = NSLocalizedString(@"Edit Reward", nil);
    [self.form formRowWithTag:@"text"].value = [self.reward.text stringByReplacingEmojiCheatCodesWithUnicode];
    [self.form formRowWithTag:@"notes"].value = [self.reward.notes stringByReplacingEmojiCheatCodesWithUnicode];
    [self.form formRowWithTag:@"value"].value = self.reward.value;
    
    for (Tag *tag in self.reward.tags) {
        [self.form formRowWithTag:[NSString stringWithFormat:@"tag.%@", tag.id]].value = [NSNumber numberWithBool:YES];
    }
    
    [self.tableView reloadData];
}

- (void) fetchTags {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
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
        if (!self.editReward) {
            self.reward = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Reward"
                         inManagedObjectContext:self.managedObjectContext];
            self.reward.type = @"reward";
        }
        NSDictionary *formValues = [self.form formValues];
        NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionary];
        for (NSString *key in formValues) {
            if ([key isEqualToString:@"hasDueDate"]) {
                continue;
            }
            if ([key  hasPrefix:@"tag."]) {
                if (formValues[key] != [NSNull null]) {
                    [tagDictionary setObject:formValues[key] forKey:[key substringFromIndex:4]];
                } else {
                    [tagDictionary setObject:[NSNumber numberWithBool:NO] forKey:[key substringFromIndex:4]];
                }
                continue;
            }

            
            if (formValues[key] == [NSNull null]) {
                [self.reward setValue:nil forKeyPath:key];
                continue;
            }
            if ([formValues[key] isKindOfClass:[NSString class]]) {
                [self.reward setValue:[formValues[key] stringByReplacingEmojiUnicodeWithCheatCodes] forKey:key];
                continue;
            }
            [self.reward setValue:formValues[key] forKeyPath:key];
        }
        self.reward.tagDictionary = tagDictionary;
    }
}

@end
