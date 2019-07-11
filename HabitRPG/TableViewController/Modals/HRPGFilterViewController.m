//
//  HRPGTagViewController.m
//  Habitica
//
//  Created by Phillip on 08/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFilterViewController.h"
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
    
    self.navigationItem.title = objcL10n.filterByTags;
    self.clearButton.title = objcL10n.clear;
    
    self.dataSource = [FilterTableViewDataSourceInstantiator instantiate];
    self.dataSource.tableView = self.tableView;
    self.dataSource.selectedTagIds = self.selectedTags;
    
    self.headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    if ([self.taskType isEqualToString:@"habit"]) {
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:@[
            objcL10n.all, objcL10n.weak, objcL10n.strong
        ]];
    } else if ([self.taskType isEqualToString:@"daily"]) {
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:@[
            objcL10n.all, objcL10n.due, objcL10n.grey
        ]];
    } else if ([self.taskType isEqualToString:@"todo"]) {
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:@[
            objcL10n.active, objcL10n.dated, objcL10n.done
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
    
    self.tableView.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
    
    [self doneButtonTapped:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    if (self.selectedTags == nil) {
        self.selectedTags = [[NSMutableArray alloc] init];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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
    self.selectedTags = self.dataSource.selectedTagIds;
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
        title = objcL10n.editTag;
        self.editedTag = tag;
    } else {
        title = objcL10n.createTag;
    self.editedTag = nil;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction cancelActionWithHandler:nil]];
     [alertController addAction:[UIAlertAction actionWithTitle:objcL10n.save style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataSource deleteTagAt: indexPath];
    }
}

@end
