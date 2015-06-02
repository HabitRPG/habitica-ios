//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGCustomizationsOverviewController.h"
#import "HRPGAppDelegate.h"
#import "Customization.h"
#import "User.h"
#import "Gear.h"
#import "HRPGCustomizationCollectionViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HRPGCustomizationsOverviewController ()
@property NSString *readableName;
@property NSString *typeName;
@property User *user;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGCustomizationsOverviewController
Gear *selectedGear;
NSIndexPath *selectedIndex;

-(void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    if (tableSelection) {
        if (tableSelection.section == 1) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[tableSelection] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Body", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Hair", nil);
    } else {
        return NSLocalizedString(@"Background", nil);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 6;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SizeCell" forIndexPath:indexPath];
        UISegmentedControl *sizeControl = (UISegmentedControl*)[cell viewWithTag:1];
        if ([self.user.size isEqualToString:@"slim"]) {
            [sizeControl setSelectedSegmentIndex:0];
        } else {
            [sizeControl setSelectedSegmentIndex:1];
        }
        return cell;
    }
    NSString *cellName = @"Cell";
    if (indexPath.section == 2) {
        cellName = @"BackgroundCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 50;
    } if (indexPath.section == 2) {
        return 148;
    }
    return 76;
}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"purchased == True || price == 0"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[typeDescriptor, nameDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    [tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    NSString *searchedKey;
    NSString *typeName;
    NSString *searchedType;
    NSString *searchedGroup;
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            searchedKey = self.user.size;
            searchedType = @"size";
            typeName = NSLocalizedString(@"Size", nil);
        } else if (indexPath.item == 1) {
            searchedKey = self.user.shirt;
            searchedType = @"shirt";
            typeName = NSLocalizedString(@"Shirt", nil);
        } else if (indexPath.item == 2) {
            searchedKey = self.user.skin;
            searchedType = @"skin";
            typeName = NSLocalizedString(@"Skin", nil);
        } else if (indexPath.item == 3) {
            if ([self.user.useCostume boolValue]) {
                searchedKey = self.user.costumeHeadAccessory;
            } else {
                searchedKey = self.user.equippedHeadAccessory;
            }
            searchedType = @"ear";
            typeName = NSLocalizedString(@"Animal Ears", nil);
        }
    } else if (indexPath.section == 1) {
        searchedType = @"hair";
        if (indexPath.item == 0) {
            searchedGroup = @"color";
            searchedKey = self.user.hairColor;
            typeName = NSLocalizedString(@"Color", nil);
        } else if (indexPath.item == 1) {
            searchedGroup = @"base";
            searchedKey = self.user.hairBase;
            typeName = NSLocalizedString(@"Base", nil);
        } else if (indexPath.item == 2) {
            searchedGroup = @"bangs";
            searchedKey = self.user.hairBangs;
            typeName = NSLocalizedString(@"Bangs", nil);
        } else if (indexPath.item == 3) {
            searchedGroup = @"flower";
            searchedKey = self.user.hairFlower;
            typeName = NSLocalizedString(@"Flower", nil);
        } else if (indexPath.item == 4) {
            searchedGroup = @"beard";
            searchedKey = self.user.hairBeard;
            typeName = NSLocalizedString(@"Beard", nil);
        } else if (indexPath.item == 5) {
            searchedGroup = @"mustache";
            searchedKey = self.user.hairMustache;
            typeName = NSLocalizedString(@"Mustache", nil);
        }
    } else {
        if (indexPath.item == 0) {
            searchedKey = self.user.background;
            searchedType = @"background";
            typeName = NSLocalizedString(@"Background", nil);
        }
    }
    
    textLabel.text = typeName;
    UILabel *detailLabel = (UILabel*)[cell viewWithTag:2];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];
    
    if ([searchedType isEqualToString:@"ear"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"type == 'headAccessory' && key == %@ && set == 'animal'", searchedKey];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (results.count > 0) {
            Gear *equippedEar = results[0];
            detailLabel.text = equippedEar.text;
            detailLabel.textColor = [UIColor blackColor];
            imageView.contentMode = UIViewContentModeCenter;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/shop_%@.png", equippedEar.key]]
                         placeholderImage:[UIImage imageNamed:@"Placeholder"]];
            imageView.alpha = 1.0;
        } else {
            detailLabel.text = NSLocalizedString(@"Nothing Set", nil);
            detailLabel.textColor = [UIColor grayColor];
            [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/head_0.png"]
                         placeholderImage:[UIImage imageNamed:@"Placeholder"]];
            imageView.alpha = 0.4;
        }
    } else {
        Customization *searchedCustomization;
        if (searchedKey && ![searchedKey isEqualToString:@""]) {
            for (Customization *customization in self.fetchedResultsController.fetchedObjects) {
                if ([customization.name isEqualToString:searchedKey] && [customization.type isEqualToString:searchedType]) {
                    if (searchedGroup) {
                        if (![searchedGroup isEqualToString:customization.group]) {
                            continue;
                        }
                    }
                    searchedCustomization = customization;
                    break;
                }
            }
            
        }
        if (searchedCustomization && ![searchedCustomization.name isEqualToString:@"0"]) {
            detailLabel.text = [searchedCustomization.name capitalizedString];
            detailLabel.textColor = [UIColor blackColor];
            imageView.contentMode = UIViewContentModeBottomRight;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/%@.png", [searchedCustomization getImageNameForUser:self.user]]]
                         placeholderImage:[UIImage imageNamed:@"Placeholder"]];
            imageView.alpha = 1.0;
        } else {
            detailLabel.text = NSLocalizedString(@"Nothing Set", nil);
            detailLabel.textColor = [UIColor grayColor];
            [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/head_0.png"]
                         placeholderImage:[UIImage imageNamed:@"Placeholder"]];
            imageView.alpha = 0.4;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        HRPGCustomizationCollectionViewController *destViewController = (HRPGCustomizationCollectionViewController*)segue.destinationViewController;
        destViewController.user = self.user;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destViewController.entityName = @"Customization";
        if (indexPath.section == 0) {
            if (indexPath.item == 1) {
                destViewController.userKey = @"preferences.shirt";
                destViewController.type = @"shirt";
            } else if (indexPath.item == 2) {
                destViewController.userKey = @"preferences.skin";
                destViewController.type = @"skin";
            } else if (indexPath.item == 3) {
                destViewController.entityName = @"Gear";
                if ([self.user.useCostume boolValue]) {
                    destViewController.userKey = @"costume";
                } else {
                    destViewController.userKey = @"equipped";
                }
                destViewController.type = @"ear";
            }
        } else if (indexPath.section == 1) {
            destViewController.type = @"hair";
            switch (indexPath.item) {
                case 0:
                    destViewController.userKey = @"preferences.hair.color";
                    destViewController.group = @"color";
                    break;
                case 1:
                    destViewController.userKey = @"preferences.hair.base";
                    destViewController.group = @"base";
                    break;
                case 2:
                    destViewController.userKey = @"preferences.hair.bangs";
                    destViewController.group = @"bangs";
                    break;
                case 3:
                    destViewController.userKey = @"preferences.hair.flower";
                    destViewController.group = @"flower";
                    break;
                case 4:
                    destViewController.userKey = @"preferences.hair.beard";
                    destViewController.group = @"beard";
                    break;
                case 5:
                    destViewController.userKey = @"preferences.hair.mustache";
                    destViewController.group = @"mustache";
                    break;
                    
                default:
                    break;
            }
        } else {
            destViewController.userKey = @"preferences.background";
            destViewController.type = @"background";
        }
    }
}

- (IBAction)userSizeChanged:(UISegmentedControl*)sender {
    NSString *newSize;
    if (sender.selectedSegmentIndex == 0) {
        newSize = @"slim";
    } else {
        newSize = @"broad";
    }
    
    [self.sharedManager updateUser:@{@"preferences.size": newSize} onSuccess:^() {
        
    }onError:^() {
        
    }];
}

@end
