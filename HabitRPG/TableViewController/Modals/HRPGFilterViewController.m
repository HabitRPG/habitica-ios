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

@property(nonatomic) NSFetchedResultsController *fetchedResultsController;
@property UIView *headerView;
@property UISegmentedControl *filterTypeControl;
@property NSMutableArray *areTagsSelected;
@property (nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic) IBOutlet UIBarButtonItem *toolBarSpace;

@property Tag *editedTag;
@end

@implementation HRPGFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.areTagsSelected =
        [NSMutableArray arrayWithCapacity:self.fetchedResultsController.fetchedObjects.count];

    for (Tag *tag in self.fetchedResultsController.fetchedObjects) {
        [self.areTagsSelected addObject:@NO];
        for (NSString *selectedTag in self.selectedTags) {
            if ([tag.id isEqualToString:selectedTag]) {
                self.areTagsSelected[self.areTagsSelected.count - 1] = @YES;
                break;
            }
        }
    }

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.fetchedResultsController sections][section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell;
    if ([tag.challenge boolValue]) {
        cell =
            [tableView dequeueReusableCellWithIdentifier:@"ChallengeCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger height = [tag.name boundingRectWithSize:CGSizeMake(260.0f, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                               NSFontAttributeName : [UIFont
                                                   preferredFontForTextStyle:UIFontTextStyleBody]
                                           }
                                              context:nil]
                           .size.height +
                       42;
    return height;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.areTagsSelected addObject:@NO];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            if (self.areTagsSelected.count > indexPath.item) {
                [self.areTagsSelected removeObjectAtIndex:indexPath.item];
                [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath
                  withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = [cell viewWithTag:1];
    textLabel.text = tag.name;

    HRPGCheckBoxView *checkboxView = [cell viewWithTag:2];
    checkboxView.cornerRadius = checkboxView.size / 2;
    if ([self.areTagsSelected[indexPath.item] boolValue]) {
        checkboxView.checkColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        checkboxView.boxBorderColor = ObjcThemeWrapper.backgroundTintColor;
        checkboxView.boxFillColor = ObjcThemeWrapper.backgroundTintColor;
    } else {
        checkboxView.boxFillColor = [UIColor clearColor];
        checkboxView.boxBorderColor = ObjcThemeWrapper.backgroundTintColor;
        checkboxView.checkColor = [UIColor clearColor];
    }
    checkboxView.checked = [self.areTagsSelected[indexPath.item] boolValue];
    [checkboxView.layer setNeedsDisplay];

    if (tag.challenge) {
        UIImageView *imageView = [cell viewWithTag:3];
        imageView.image = [UIImage imageNamed:@"challenge"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self showFormAlertForTag:tag];
    } else {
        self.areTagsSelected[indexPath.item] = @(![self.areTagsSelected[indexPath.item] boolValue]);
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                              withRowAnimation:UITableViewRowAnimationNone];
    }

}

- (IBAction)clearTags:(id)sender {
    for (int i = 0; i < self.areTagsSelected.count; i++) {
        self.areTagsSelected[i] = @NO;
    }
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UnwindTagSegue"]) {
        int counter = 0;
        [self.selectedTags removeAllObjects];
        for (Tag *tag in [self.fetchedResultsController fetchedObjects]) {
            if ([self.areTagsSelected[counter] boolValue]) {
                if (![self.selectedTags containsObject:tag.id]) {
                    [self.selectedTags addObject:tag.id];
                }
            }
            counter++;
        }
    }
}

- (void)filterTypeChanged:(UISegmentedControl *)segment {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:segment.selectedSegmentIndex
                  forKey:[NSString stringWithFormat:@"%@Filter", self.taskType]];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"taskFilterChanged" object:nil];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[HRPGManager sharedManager] deleteTag:tag
                             onSuccess:nil onError:nil];
    }
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

- (void)showFormAlertForTag:(Tag *)tag {
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
             self.editedTag.name = newTagName;
             [[HRPGManager sharedManager] updateTag:self.editedTag onSuccess:nil onError:nil];
             self.editedTag = nil;
         } else {
             Tag *newTag =
             [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                           inManagedObjectContext:self.managedObjectContext];
             newTag.name = newTagName;
             newTag.order = [NSNumber numberWithInteger:self.fetchedResultsController.fetchedObjects.count];
             [[HRPGManager sharedManager] createTag:newTag onSuccess:nil onError:nil];
         }
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (tag) {
            textField.text = tag.name;
        }
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
