//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGEquipmentDetailViewController.h"
#import "HRPGAppDelegate.h"
#import "Gear.h"
#import "User.h"

@interface HRPGEquipmentDetailViewController ()
@property User *user;
@property NSIndexPath *equippedIndex;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGEquipmentDetailViewController
Gear *selectedGear;
NSIndexPath *selectedIndex;

-(void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
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
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
    float height = 22.0f;
    height = height + [gear.text boundingRectWithSize:CGSizeMake(247.0f, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                                          }
                                                context:nil].size.height;
    height = height + [gear.notes boundingRectWithSize:CGSizeMake(247.0f, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                               NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                                               }
                                                     context:nil].size.height;
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
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath;
    NSString *gearString;
    Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.equipType isEqualToString:@"equipped"]) {
        if ([gear isEquippedBy:self.user]) {
            gearString = NSLocalizedString(@"Unequip", nil);
        } else {
            gearString = NSLocalizedString(@"Equip", nil);
        }
    } else {
        if ([gear isCostumeOf:self.user]) {
            gearString = NSLocalizedString(@"Unequip", nil);
        } else {
            gearString = NSLocalizedString(@"Equip", nil);
        }
    }
    selectedGear = gear;
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            gearString,
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
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
    predicate = [NSPredicate predicateWithFormat:@"owned == True && type == %@", self.type];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSSortDescriptor *classDescriptor = [[NSSortDescriptor alloc] initWithKey:@"klass" ascending:YES];
    NSArray *sortDescriptors = @[classDescriptor, indexDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"klass" cacheName:nil];
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
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:2];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    textLabel.text = gear.text;
    detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    detailTextLabel.text = gear.notes;
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/shop_%@.png", gear.key]]
              placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    
    UILabel *equippedLabel = (UILabel*)[cell viewWithTag:4];
    equippedLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    equippedLabel.textAlignment = NSTextAlignmentRight;
    if ([self.equipType isEqualToString:@"equipped"]) {
        if ([gear isEquippedBy:self.user]) {
            equippedLabel.text = NSLocalizedString(@"equipped", nil);
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            self.equippedIndex = indexPath;
        } else {
            equippedLabel.text = nil;
            cell.backgroundColor = [UIColor whiteColor];
        }
    } else {
        if ([gear isCostumeOf:self.user]) {
            equippedLabel.text = NSLocalizedString(@"equipped", nil);
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            self.equippedIndex = indexPath;
        } else {
            equippedLabel.text = nil;
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self addActivityCounter];
        [self.sharedManager equipObject:selectedGear.key withType:self.equipType onSuccess:^() {
            if (self.equippedIndex && self.equippedIndex != selectedIndex) {
                [self.tableView reloadRowsAtIndexPaths:@[selectedIndex, self.equippedIndex] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self.tableView reloadRowsAtIndexPaths:@[selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
            }
            if ([self.equipType isEqualToString:@"equipped"]) {
                if ([selectedGear isEquippedBy:self.user]) {
                    self.equippedIndex = selectedIndex;
                } else {
                    self.equippedIndex = nil;
                }
            } else {
                if ([selectedGear isCostumeOf:self.user]) {
                    self.equippedIndex = selectedIndex;
                } else {
                    self.equippedIndex = nil;
                }
            }
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


@end
