//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGItemViewController.h"
#import "HRPGAppDelegate.h"
#import "Item.h"
#import "Quest.h"
#import "HatchingPotion.h"
#import "Egg.h"
#import "Group.h"
#import "User.h"
#import "Pet.h"
#import "HRPGPetHatchedOverlayView.h"

@interface HRPGItemViewController ()
@property HRPGManager *sharedManager;
@property Item *selectedItem;
@property NSIndexPath *selectedIndex;
@property BOOL isHatching;
@property NSArray *existingPets;
@property UIBarButtonItem *backButton;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGItemViewController
@synthesize managedObjectContext;
@dynamic sharedManager;

- (void) fetchExistingPetsWithPartName:(NSString*)string {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"key contains[cd] %@ && trained > 0", string];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    self.existingPets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

-(void) showCancelButton {
    self.backButton = self.navigationItem.leftBarButtonItem;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(endHatching)];
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
}

-(void) showBackButton {
    [self.navigationItem setLeftBarButtonItem:self.backButton animated:YES];
}

-(void)endHatching {
    [self showBackButton];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owned > 0"];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    self.isHatching = NO;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
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
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger height = [item.text boundingRectWithSize:CGSizeMake(260.0f, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                    NSFontAttributeName : [UIFont systemFontOfSize:18.0f]
                                            }
                                               context:nil].size.height + 22;
    if (height < 60) {
        return 60;
    }
    return height;
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
    self.selectedIndex = indexPath;
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.isHatching) {
        for (Pet *pet in self.existingPets) {
            if ([pet.key rangeOfString:item.key].location != NSNotFound) {
                return;
            }
        }
        [self addActivityCounter];
        HRPGPetHatchedOverlayView *phView = [[HRPGPetHatchedOverlayView alloc] init];
        
        if ([self.selectedItem isKindOfClass:[HatchingPotion class]]) {
            [phView.petImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/Pet-%@-%@.png", item.key, self.selectedItem.key]] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
            phView.hatchString = [NSString stringWithFormat:NSLocalizedString(@"You hatched a %@ %@!", nil), self.selectedItem.text, item.key];
            [self.sharedManager hatchEgg:item.key withPotion:self.selectedItem.key onSuccess:^() {
                [self removeActivityCounter];
                [phView display:^() {
                }];
            }onError:^() {
                [self removeActivityCounter];
            }];
        } else {
            [phView.petImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/Pet-%@-%@.png", self.selectedItem.key, item.key]] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
            phView.hatchString = [NSString stringWithFormat:NSLocalizedString(@"You hatched a %@ %@!", nil), item.key, self.selectedItem.text];
            [self.sharedManager hatchEgg:self.selectedItem.key withPotion:item.key onSuccess:^() {
                [self removeActivityCounter];
                [phView display:^() {
                }];
            }onError:^() {
                [self removeActivityCounter];
            }];
        }
        [self endHatching];
        return;
    }
    NSString *extraItem;
    if ([item isKindOfClass:[Quest class]]) {
        extraItem = NSLocalizedString(@"Invite Party", nil);
    } else if ([item isKindOfClass:[HatchingPotion class]]) {
        extraItem = NSLocalizedString(@"Hatch Egg", nil);
    } else if ([item isKindOfClass:[Egg class]]) {
        extraItem = NSLocalizedString(@"Hatch with Potion", nil);
    }
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Sell", nil) otherButtonTitles:extraItem, nil];
    popup.tag = 1;
    self.selectedItem = item;
    [popup showInView:[UIApplication sharedApplication].keyWindow];}

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"owned > 0"];
    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self addActivityCounter];
        [self.sharedManager sellItem:self.selectedItem onSuccess:^() {
            [self removeActivityCounter];
        }onError:^() {
            [self removeActivityCounter];
        }];
    } if (buttonIndex == 1) {
        if ([self.selectedItem isKindOfClass:[Quest class]]) {
            [self addActivityCounter];
            User *user = [self.sharedManager getUser];
            Quest *quest = (Quest*)self.selectedItem;
            [self.sharedManager acceptQuest:user.party.id withQuest:quest useForce:NO onSuccess:^(){
                [self removeActivityCounter];
            }onError:^() {
                [self removeActivityCounter];
            }];
        } else if ([self.selectedItem isKindOfClass:[HatchingPotion class]]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 'eggs' && owned > 0"];
            self.isHatching = YES;
            [self.fetchedResultsController.fetchRequest setPredicate:predicate];
            NSError *error;
            [self.fetchedResultsController performFetch:&error];
            [self.tableView reloadData];
            [self fetchExistingPetsWithPartName:self.selectedItem.key];
            [self showCancelButton];
        } else if ([self.selectedItem isKindOfClass:[Egg class]]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 'hatchingPotions' && owned > 0"];
            [self.fetchedResultsController.fetchRequest setPredicate:predicate];
            self.isHatching = YES;
            NSError *error;
            [self.fetchedResultsController performFetch:&error];
            [self.tableView reloadData];
            [self fetchExistingPetsWithPartName:self.selectedItem.key];
            [self showCancelButton];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel *) [cell viewWithTag:1];
    textLabel.text = item.text;
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UILabel *detailTextLabel = (UILabel *) [cell viewWithTag:2];
    detailTextLabel.text = [NSString stringWithFormat:@"%@", item.owned];
    detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [detailTextLabel sizeToFit];
    NSString *url;
    if ([item.type isEqualToString:@"quests"]) {
        url = @"http://pherth.net/habitrpg/inventory_quest_scroll.png";
    } else {
        NSString *type;
        if ([item.type isEqualToString:@"eggs"]) {
            type = @"Egg";
        } else if ([item.type isEqualToString:@"food"]) {
            type = @"Food";
        } else if ([item.type isEqualToString:@"hatchingPotions"]) {
            type = @"HatchingPotion";
        }
        url = [NSString stringWithFormat:@"http://pherth.net/habitrpg/Pet_%@_%@.png", type, item.key];
    }
    [cell.imageView setImageWithURL:[NSURL URLWithString:url]
                   placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.alpha = 1;
    textLabel.alpha = 1;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (self.isHatching) {
        for (Pet *pet in self.existingPets) {
            if ([pet.key rangeOfString:item.key].location != NSNotFound) {
                cell.imageView.alpha = 0.4;
                textLabel.alpha = 0.4;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            }
        }
    }
}

@end
