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
#import "HRPGEquipmentDetailViewController.h"

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

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    if (tableSelection) {
        [self.tableView reloadRowsAtIndexPaths:@[tableSelection] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Battle Gear", nil);
    } else {
        return NSLocalizedString(@"Costume", nil);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return NO;
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    NSString *searchedKey;
    NSString *typeName;
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            searchedKey = self.user.equippedHead;
            typeName = NSLocalizedString(@"Head", nil);
        } else if (indexPath.item == 1) {
            searchedKey = self.user.equippedHeadAccessory;
            typeName = NSLocalizedString(@"Head Accessory", nil);
        } else if (indexPath.item == 2) {
            searchedKey = self.user.equippedArmor;
            typeName = NSLocalizedString(@"Armor", nil);
        } else if (indexPath.item == 3) {
            searchedKey = self.user.equippedBack;
            typeName = NSLocalizedString(@"Back", nil);
        } else if (indexPath.item == 4) {
            searchedKey = self.user.equippedShield;
            typeName = NSLocalizedString(@"Shield", nil);
        } else if (indexPath.item == 5) {
            searchedKey = self.user.equippedWeapon;
            typeName = NSLocalizedString(@"Weapon", nil);
        }
    } else {
        if (indexPath.item == 0) {
            searchedKey = self.user.costumeHead;
            typeName = NSLocalizedString(@"Head", nil);
        } else if (indexPath.item == 1) {
            searchedKey = self.user.costumeHeadAccessory;
            typeName = NSLocalizedString(@"Head Accessory", nil);
        } else if (indexPath.item == 2) {
            searchedKey = self.user.costumeArmor;
            typeName = NSLocalizedString(@"Armor", nil);
        } else if (indexPath.item == 3) {
            searchedKey = self.user.costumeBack;
            typeName = NSLocalizedString(@"Back", nil);
        } else if (indexPath.item == 4) {
            searchedKey = self.user.costumeShield;
            typeName = NSLocalizedString(@"Shield", nil);
        } else if (indexPath.item == 5) {
            searchedKey = self.user.costumeWeapon;
            typeName = NSLocalizedString(@"Weapon", nil);
        }
    }
    Gear *searchedGear;
    for (Gear *gear in self.fetchedResultsController.fetchedObjects) {
        if ([gear.key isEqualToString:searchedKey]) {
            searchedGear = gear;
            break;
        }
    }
    textLabel.text = typeName;
    UILabel *detailLabel = (UILabel*)[cell viewWithTag:3];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:4];
    if (searchedGear) {
        detailLabel.text = searchedGear.text;
        detailLabel.textColor = [UIColor blackColor];

        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/shop_%@.png", searchedGear.key]]
                    placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    } else {
        detailLabel.text = NSLocalizedString(@"Nothing Equipped", nil);
        detailLabel.textColor = [UIColor grayColor];
        imageView.image = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EquipmentDetailSegue"]) {
        HRPGEquipmentDetailViewController *equipmentDetailViewController = (HRPGEquipmentDetailViewController*)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath.item == 0) {
            equipmentDetailViewController.type = @"head";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Head", nil);
        } else if (indexPath.item == 1) {
            equipmentDetailViewController.type = @"headAccessory";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Head Accessory", nil);
        } else if (indexPath.item == 2) {
            equipmentDetailViewController.type = @"armor";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Armor", nil);
        } else if (indexPath.item == 3) {
            equipmentDetailViewController.type = @"back";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Back", nil);
        } else if (indexPath.item == 4) {
            equipmentDetailViewController.type = @"shield";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Shield", nil);
        } else if (indexPath.item == 5) {
            equipmentDetailViewController.type = @"weapon";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Weapon", nil);
        }
        
        if (indexPath.section == 0) {
            equipmentDetailViewController.equipType = @"equipped";
        } else if (indexPath.section == 1) {
            equipmentDetailViewController.equipType = @"costume";
        }
    }
}

@end
