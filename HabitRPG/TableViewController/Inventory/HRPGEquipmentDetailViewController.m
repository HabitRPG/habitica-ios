//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGEquipmentDetailViewController.h"
#import "Gear.h"

@interface HRPGEquipmentDetailViewController ()
@property User *user;
@property NSIndexPath *equippedIndex;
- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate;
@end

@implementation HRPGEquipmentDetailViewController
Gear *selectedGear;
NSIndexPath *selectedIndex;
float textWidth;

- (void)viewDidLoad {
    self.user = [self.sharedManager getUser];
    [super viewDidLoad];

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    textWidth = (float) (screenRect.size.width - 73.0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.fetchedResultsController sections][(NSUInteger) section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][(NSUInteger) section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
    float height = 22.0f;
    height = height +
             [gear.text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{
                                      NSFontAttributeName :
                                          [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                  }
                                     context:nil]
                 .size.height;
    height = height +
             [gear.notes boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{
                                       NSFontAttributeName : [UIFont
                                           preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                   }
                                      context:nil]
                 .size.height;
    return height;
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
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:gearString, nil];
    popup.tag = 1;

    // get the selected cell so that the popup can be displayed near it on the iPad
    UITableViewCell *selectedCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];

    CGRect rectIPad = CGRectMake(selectedCell.frame.origin.x, selectedCell.frame.origin.y,
                                 selectedCell.frame.size.width, selectedCell.frame.size.height);
    // using the following form rather than [popup showInView:[UIApplication
    // sharedApplication].keyWindow]] to make it compatible with both iPhone and iPad
    [popup showFromRect:rectIPad inView:self.view animated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"owned == True && type == %@", self.type];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *indexDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSSortDescriptor *classDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"klass" ascending:YES];
    NSArray *sortDescriptors = @[ classDescriptor, indexDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:@"klass"
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
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
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
    Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *detailTextLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    textLabel.text = gear.text;
    detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    detailTextLabel.text = gear.notes;
    [self.sharedManager setImage:[NSString stringWithFormat:@"shop_%@", gear.key]
                      withFormat:@"png"
                          onView:imageView];

    UILabel *equippedLabel = (UILabel *)[cell viewWithTag:4];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];
    if (buttonIndex == 0) {
        [self.sharedManager
            equipObject:selectedGear.key
               withType:self.equipType
              onSuccess:^() {
                  if (self.equippedIndex && (self.equippedIndex.item != selectedIndex.item ||
                                             self.equippedIndex.section != selectedIndex.section)) {
                      [self.tableView reloadRowsAtIndexPaths:@[ selectedIndex, self.equippedIndex ]
                                            withRowAnimation:UITableViewRowAnimationFade];
                  } else {
                      [self.tableView reloadRowsAtIndexPaths:@[ selectedIndex ]
                                            withRowAnimation:UITableViewRowAnimationFade];
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
              }
                onError:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];
}

@end
