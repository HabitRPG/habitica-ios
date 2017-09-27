//
//  HRPGCustomizationCollectionViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/05/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCustomizationCollectionViewController.h"
#import "HRPGManager.h"
#import "Customization.h"
#import "Gear.h"
#import "HRPGPurchaseButton.h"
#import "Habitica-Swift.h"
#import "InAppReward+CoreDataClass.h"

@interface HRPGCustomizationCollectionViewController ()
@property(nonatomic) NSFetchedResultsController *fetchedResultsController;
@property UIBarButtonItem *navigationButton;
@property CGSize screenSize;
@property id selectedCustomization;
@property NSString *selectedSetPath;
@property NSNumber *setPrice;
@property NSMutableDictionary<NSString *, InAppReward *> *pinnedItems;
@end

@implementation HRPGCustomizationCollectionViewController

static NSString *const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.screenSize = [[UIScreen mainScreen] bounds].size;

    if ([self.type isEqualToString:@"background"]) {
        self.setPrice = @15;
    } else {
        self.setPrice = @5;
    }
}

- (void)loadPinnedItems {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"InAppReward"];
    fetchRequest.returnsObjectsAsFaults = NO;
    NSError *error = nil;
    NSArray *items = [[[HRPGManager sharedManager] getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    self.pinnedItems = [[NSMutableDictionary alloc] initWithCapacity:items.count];
    for (InAppReward *item in items) {
        [self.pinnedItems setObject:item forKey:item.key];
    }
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.screenSize.width - 46) / 4, 75.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:@"SectionCell"
                                                  forIndexPath:indexPath];
    UILabel *label = [headerView viewWithTag:1];
    label.text = [[[[[[self.fetchedResultsController sections][indexPath.section] name]
        stringByReplacingOccurrencesOfString:@"Shirts"
                                  withString:@""] stringByReplacingOccurrencesOfString:@"Skins"
                                                                             withString:@""]
        stringByReplacingOccurrencesOfString:@"backgrounds"
                                  withString:@""] uppercaseString];
    HRPGPurchaseButton *purchaseButton = [headerView viewWithTag:2];
    BOOL purchasable = NO;
    NSString *setString = @"";
    if ([self.entityName isEqualToString:@"Customization"]) {
        for (Customization *customization in
             [[self.fetchedResultsController sections][indexPath.section] objects]) {
            if ([customization.purchasable boolValue] && ![customization.purchased boolValue]) {
                purchasable = YES;
            }
            setString = [setString stringByAppendingFormat:@"%@,", [customization getPath]];
        }
    } else {
        for (Gear *gear in [[self.fetchedResultsController sections][indexPath.section] objects]) {
            if (!gear.owned) {
                purchasable = YES;
            }
            setString = [setString stringByAppendingFormat:@"items.gear.owned.%@,", gear.key];
        }
    }
    setString =
        [setString stringByPaddingToLength:setString.length - 1 withString:@"" startingAtIndex:0];
    if (purchasable) {
        purchaseButton.hidden = false;
        [purchaseButton addTarget:self
                           action:@selector(purchaseSet:)
                 forControlEvents:UIControlEventTouchUpInside];
        purchaseButton.setPath = setString;
        [purchaseButton
            setTitle:[NSString stringWithFormat:NSLocalizedString(@" Unlock Set for %@ Gems ", nil),
                                                self.setPrice]
            forState:UIControlStateNormal];
    } else {
        purchaseButton.hidden = true;
    }

    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName;

    if ([self.entityName isEqualToString:@"Customization"]) {
        Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([customization.purchased boolValue] || [customization.price integerValue] == 0) {
            cellName = @"Cell";
        } else {
            cellName = @"LockedCell";
        }
    } else {
        Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (gear.owned) {
            cellName = @"Cell";
        } else {
            cellName = @"LockedCell";
        }
    }

    UICollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath animated:NO];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *actionString = NSLocalizedString(@"Use", nil);
    NSInteger tag = 0;
    UIAlertController *alertController =  [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction cancelActionWithHandler:nil]];
    
    NSString *pinString = NSLocalizedString(@"Pin to rewards", nil);
    NSString *path = nil;
    if ([self.entityName isEqualToString:@"Customization"]) {
        Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];

        if (![customization.purchased boolValue] && [customization.price integerValue] > 0) {
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Purchase for %@ Gems", nil), customization.price];
            tag = 1;
        }
        if (self.pinnedItems[customization.name]) {
            pinString = NSLocalizedString(@"Unpin from Rewards", nil);
        }
        path = [NSString stringWithFormat:@"backgrounds.%@.%@", customization.set, customization.name];
        self.selectedCustomization = customization;

    } else {
        Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];

        if (!gear.owned) {
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Purchase for 2 Gems", nil)];
            tag = 1;
        }
        if (self.pinnedItems[gear.key]) {
            pinString = NSLocalizedString(@"Unpin from Rewards", nil);
        }
        
        self.selectedCustomization = gear;
    }
    
    __weak HRPGCustomizationCollectionViewController *weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:actionString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        switch (tag) {
            case 0:
                if ([self.entityName isEqualToString:@"Customization"]) {
                    [[HRPGManager sharedManager] updateUser:@{
                                                              self.userKey : [self.selectedCustomization valueForKey:@"name"]
                                                              }
                                                  onSuccess:nil onError:nil];
                } else {
                    [[HRPGManager sharedManager] equipObject:[self.selectedCustomization valueForKey:@"key"]
                                                    withType:self.userKey
                                                   onSuccess:nil onError:nil];
                }
                break;
            case 1:
                if ([self.entityName isEqualToString:@"Customization"]) {
                    if ([self.user.balance floatValue] <
                        [[self.selectedCustomization valueForKey:@"price"] floatValue] / 4) {
                        [self displayGemPurchaseView];
                        return;
                    }
                    [[HRPGManager sharedManager] unlockPath:[self.selectedCustomization getPath]
                                                  onSuccess:nil onError:nil];
                } else {
                    if ([self.user.balance floatValue] < 0.5) {
                        [self displayGemPurchaseView];
                        return;
                    }
                    Gear *gear = self.selectedCustomization;
                    [[HRPGManager sharedManager] purchaseItem:gear.key withPurchaseType:gear.type withText:gear.text withImageName:[@"shop_" stringByAppendingString:gear.key] onSuccess:^() {
                        if (weakSelf) {
                            [weakSelf.collectionView reloadData];
                        }
                    } onError:nil];
                }
                break;
            default:
                break;
        }
    }]];
    
    if ([@"background" isEqualToString:self.type]) {
        [alertController addAction:[UIAlertAction actionWithTitle:pinString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[HRPGManager sharedManager] togglePinnedItem:weakSelf.type withPath:path onSuccess:^() {
                if (weakSelf) {
                    [weakSelf.collectionView reloadData];
                }
            } onError:nil];
        }]];
    }
    
    alertController.popoverPresentationController.sourceView = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *typeSortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"set" ascending:YES];
    NSArray *sortDescriptors;
    if ([self.entityName isEqualToString:@"Customization"]) {
        if (self.group) {
            [fetchRequest
                setPredicate:[NSPredicate predicateWithFormat:@"(purchasable == true || purchased "
                                                              @"== true || price == 0) && type == "
                                                              @"%@ && group == %@",
                                                              self.type, self.group]];
        } else {
            [fetchRequest
                setPredicate:[NSPredicate predicateWithFormat:@"(purchasable == true || purchased "
                                                              @"== true || price == 0) && type == "
                                                              @"%@",
                                                              self.type]];
        }
        NSSortDescriptor *sortDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        sortDescriptors = @[ typeSortDescriptor, sortDescriptor ];
    } else {
        [fetchRequest
            setPredicate:[NSPredicate
                             predicateWithFormat:@"set == 'animal' && type == 'headAccessory'"]];
        NSSortDescriptor *sortDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
        sortDescriptors = @[ typeSortDescriptor, sortDescriptor ];
    }

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:@"set"
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

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    UICollectionView *collectionView = self.collectionView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            break;

        case NSFetchedResultsChangeDelete:
            [collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            break;

        case NSFetchedResultsChangeMove:
            [collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
            [collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            break;
    }
}

- (void)configureCell:(UICollectionViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
             animated:(BOOL)animated {
    if ([self.entityName isEqualToString:@"Customization"]) {
        Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIImageView *imageView = [cell viewWithTag:1];
        [[HRPGManager sharedManager] setImage:[customization getImageNameForUser:self.user]
                          withFormat:@"png"
                              onView:imageView];
    } else {
        Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIImageView *imageView = [cell viewWithTag:1];
        [[HRPGManager sharedManager] setImage:[NSString stringWithFormat:@"shop_%@", gear.key]
                          withFormat:@"png"
                              onView:imageView];
    }
}

- (void)purchaseSet:(HRPGPurchaseButton *)button {
    self.selectedSetPath = button.setPath;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString
                                                                                      stringWithFormat:NSLocalizedString(
                                                                                                                         @"This set can be unlocked for %@ Gems",
                                                                                                                         nil),
                                                                                      self.setPrice]
                                                                             message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction cancelActionWithHandler:nil]];
    __weak HRPGCustomizationCollectionViewController *weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock for %@ Gems", nil), self.setPrice] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([weakSelf.user.balance floatValue] < [self.setPrice floatValue] / 4) {
            [weakSelf displayGemPurchaseView];
            return;
        }
        [[HRPGManager sharedManager] unlockPath:weakSelf.selectedSetPath
                                      onSuccess:^() {
                                          if (weakSelf) {
                                              [weakSelf.collectionView reloadData];
                                          }
                                      } onError:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)displayGemPurchaseView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController =
        [storyboard instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
