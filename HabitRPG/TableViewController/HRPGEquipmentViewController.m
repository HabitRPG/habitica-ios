//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGEquipmentViewController.h"
#import "HRPGAppDelegate.h"
#import "Gear.h"
#import "User.h"

@interface HRPGEquipmentViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@property User *user;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGEquipmentViewController
@synthesize managedObjectContext;
@dynamic sharedManager;
Gear *selectedGear;
NSIndexPath *selectedIndex;

-(void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.fetchedResultsController sections][section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath;
    NSString *battleGearString;
    NSString *costumeString;
    Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([gear isEquippedBy:self.user]) {
        battleGearString = NSLocalizedString(@"Unequip as Battle Gear", nil);
    } else {
        battleGearString = NSLocalizedString(@"Equip as Battle Gear", nil);
    }
    
    if ([gear isCostumeOf:self.user]) {
        costumeString = NSLocalizedString(@"Unequip as Costume", nil);
    } else {
        costumeString = NSLocalizedString(@"Equip as Costume", nil);
    }
    selectedGear = gear;
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            battleGearString,
                            costumeString,
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}


- (IBAction)editButtonSelected:(id)sender {
    if ([self isEditing]) {
        [self setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected:)];
    } else {
        [self setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonSelected:)];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {

}


- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {

}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"owned == True"];
    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSArray *sortDescriptors = @[typeDescriptor, indexDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"type" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    textLabel.text = gear.text;
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    UILabel *classLabel = (UILabel*)[cell viewWithTag:2];
    classLabel.text = gear.klass;
    classLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    if ([gear.klass isEqualToString:@"warrior"]) {
        classLabel.textColor = [UIColor colorWithRed:0.792 green:0.267 blue:0.239 alpha:1.000];
    } else if ([gear.klass isEqualToString:@"wizard"]) {
        classLabel.textColor = [UIColor colorWithRed:0.211 green:0.718 blue:0.168 alpha:1.000];
    } else if ([gear.klass isEqualToString:@"rogue"]) {
        classLabel.textColor = [UIColor colorWithRed:0.177 green:0.333 blue:0.559 alpha:1.000];
    } else if ([gear.klass isEqualToString:@"healer"]) {
        classLabel.textColor = [UIColor colorWithRed:0.304 green:0.702 blue:0.839 alpha:1.000];
    } else {
        classLabel.textColor = [UIColor colorWithRed:0.639 green:0.600 blue:0.022 alpha:1.000];
    }
    
    UILabel *detailLabel = (UILabel*)[cell viewWithTag:3];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    if ([gear.intelligence integerValue] != 0) {
        detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Intelligence: %@", nil), gear.intelligence];
    } else if ([gear.str integerValue] != 0) {
        detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Strength: %@", nil), gear.str];
    } else if ([gear.con integerValue] != 0) {
        detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Constitution: %@", nil), gear.con];
    } else if ([gear.per integerValue] != 0) {
        detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Perception: %@", nil), gear.per];
    } else {
        detailLabel.text = NSLocalizedString(@"No Effect", nil);
    }
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:4];
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/shop_%@.png", gear.key]]
                   placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    
    UILabel *cLabel = (UILabel*)[cell viewWithTag:5];
    UILabel *bLabel = (UILabel*)[cell viewWithTag:6];

    if ([gear isEquippedBy:self.user]) {
        bLabel.hidden = NO;
    } else {
        bLabel.hidden = YES;
    }
    if ([gear isCostumeOf:self.user]) {
        cLabel.hidden = NO;
    } else {
        cLabel.hidden = YES;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self addActivityCounter];
        [self.sharedManager equipObject:selectedGear.key withType:@"equipped" onSuccess:^() {
            [self.tableView reloadData];
            [self removeActivityCounter];
        }onError:^() {
            [self removeActivityCounter];
        }];
    } else if (buttonIndex == 1) {
        [self addActivityCounter];
        [self.sharedManager equipObject:selectedGear.key withType:@"costume" onSuccess:^() {
            [self.tableView reloadData];
            [self removeActivityCounter];
        }onError:^() {
            [self removeActivityCounter];
        }];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        UINavigationController *destViewController = segue.destinationViewController;
        destViewController.topViewController.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Add %@", nil), self.readableName];
    }
}

@end
