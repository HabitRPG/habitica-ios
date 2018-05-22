//
//  HRPGTagViewController.m
//  Habitica
//
//  Created by Phillip on 08/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFilterViewController.h"
#import "HRPGCheckBoxView.h"
#import "Tag.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGFilterViewController ()

@property UIView *headerView;
@property UISegmentedControl *filterTypeControl;
@property (nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic) IBOutlet UIBarButtonItem *toolBarSpace;

@property id<FilterTableViewDataSourceProtocol> dataSource;

@property id<TagProtocol> editedTag;
@end

@implementation HRPGFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [FilterTableViewDataSourceInstantiator instantiate];
    self.dataSource.tableView = self.tableView;
    self.dataSource.selectedTagIds = self.selectedTags;
    
    self.headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    if ([self.taskType isEqualToString:@"habit"]) {
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:@[
            NSLocalizedString(@"All", nil), NSLocalizedString(@"Weak", nil),
            NSLocalizedString(@"Strong", nil)
        ]];
    } else if ([self.taskType isEqualToString:@"daily"]) {
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:@[
            NSLocalizedString(@"All", nil), NSLocalizedString(@"Due", nil),
            NSLocalizedString(@"Grey", nil)
        ]];
    } else if ([self.taskType isEqualToString:@"todo"]) {
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:@[
            NSLocalizedString(@"Active", nil), NSLocalizedString(@"Dated", nil),
            NSLocalizedString(@"Done", nil)
        ]];
    }
    self.filterTypeControl.frame = CGRectMake(8, (self.headerView.frame.size.height - 30) / 2,
                                              self.headerView.frame.size.width - 16, 30);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.filterTypeControl.selectedSegmentIndex =
        [defaults integerForKey:[NSString stringWithFormat:@"%@Filter", self.taskType]];
    [self.filterTypeControl addTarget:self
                               action:@selector(filterTypeChanged:)
                     forControlEvents:UIControlEventValueChanged];

    [self.headerView addSubview:self.filterTypeControl];

    self.tableView.tableHeaderView = self.headerView;
    
    [self doneButtonTapped:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    if (self.selectedTags == nil) {
        self.selectedTags = [[NSMutableArray alloc] init];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        id<TagProtocol> tag = [self.dataSource tagAtIndexPath:indexPath];
        [self showFormAlertForTag:tag];
    } else {
        [self.dataSource selectTagAt:indexPath];
    }

}

- (IBAction)clearTags:(id)sender {
    [self.dataSource clearTags];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UnwindTagSegue"]) {
        self.selectedTags = self.dataSource.selectedTagIds;
    }
}

- (void)filterTypeChanged:(UISegmentedControl *)segment {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:segment.selectedSegmentIndex
                  forKey:[NSString stringWithFormat:@"%@Filter", self.taskType]];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"taskFilterChanged" object:nil];
}

- (IBAction)editButtonTapped:(id)sender {
    [self setEditing:YES animated:YES];
    self.toolbarItems = @[self.doneButton];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self setEditing:NO animated:YES];
    self.toolbarItems = @[self.editButton, self.toolBarSpace, self.clearButton];
}


- (IBAction)addButtonTapped:(id)sender {
    [self showFormAlert];
}

- (void)showFormAlert {
    [self showFormAlertForTag:nil];
}

- (void)showFormAlertForTag:(id)tag {
    NSString *title = nil;
    if (tag) {
        title = NSLocalizedString(@"Edit Tag", nil);
        self.editedTag = tag;
    } else {
        title = NSLocalizedString(@"Create Tag", nil);
    self.editedTag = nil;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction cancelActionWithHandler:nil]];
     [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         UITextField *textField = alertController.textFields[0];
         NSString *newTagName = textField.text;
         if (self.editedTag) {
             [self.dataSource updateTagWithId:[tag valueForKey:@"id"] text:newTagName];
             self.editedTag = nil;
         } else {
             [self.dataSource createTagWithText:newTagName];
         }
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (tag) {
            textField.text = [tag valueForKey:@"text"];
        }
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
