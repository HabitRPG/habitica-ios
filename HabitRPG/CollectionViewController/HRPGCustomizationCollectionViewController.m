//
//  HRPGCustomizationCollectionViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 09/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCustomizationCollectionViewController.h"
#import "HRPGManager.H"
#import "HRPGActivityIndicator.h"
#import "HRPGAppDelegate.h"
#import "HRPGTopHeaderNavigationController.h"
#import "Customization.h"
#import "Gear.h"
#import "HRPGPurchaseButton.h"

@interface HRPGCustomizationCollectionViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) HRPGManager *sharedManager;
@property NSInteger activityCounter;
@property UIBarButtonItem *navigationButton;
@property HRPGActivityIndicator *activityIndicator;
@property CGSize screenSize;
@property id selectedCustomization;
@property NSString *selectedSetPath;
@property NSNumber *setPrice;
@end

@implementation HRPGCustomizationCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = self.sharedManager.getManagedObjectContext;
    
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
    
    HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
    [self.collectionView setContentInset:UIEdgeInsetsMake([navigationController getContentOffset],0,0,0)];
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([navigationController getContentOffset],0,0,0);
    
    if ([self.type isEqualToString:@"background"]) {
        self.setPrice = [NSNumber numberWithInt:15];
    } else {
        self.setPrice = [NSNumber numberWithInt:5];
    }
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.type isEqualToString:@"background"]) {
        return CGSizeMake(141.0f, 147.0f);
    } else {
        return CGSizeMake((self.screenSize.width-46)/4, 75.0f);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionCell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[headerView viewWithTag:1];
    label.text = [[[[[[self.fetchedResultsController sections][indexPath.section] name] stringByReplacingOccurrencesOfString:@"Shirts" withString:@""] stringByReplacingOccurrencesOfString:@"Skins" withString:@""] stringByReplacingOccurrencesOfString:@"backgrounds" withString:@""] uppercaseString];
    HRPGPurchaseButton *purchaseButton = (HRPGPurchaseButton*)[headerView viewWithTag:2];
    BOOL purchasable = NO;
    NSString *setString = @"";
    if ([self.entityName isEqualToString:@"Customization"]) {
        for (Customization *customization in [[self.fetchedResultsController sections][indexPath.section] objects]) {
            if ([customization.purchasable boolValue] && ![customization.purchased boolValue]){
                purchasable = YES;
            }
            setString = [setString stringByAppendingFormat:@"%@,", [customization getPath]];
        }
    } else {
        for (Gear *gear in [[self.fetchedResultsController sections][indexPath.section] objects]) {
            if (!gear.owned){
                purchasable = YES;
            }
            setString = [setString stringByAppendingFormat:@"items.gear.owned.%@,", gear.key];
        }
    }
    setString = [setString stringByPaddingToLength:setString.length-1 withString:nil startingAtIndex:0];
    if (purchasable) {
        purchaseButton.hidden = false;
        [purchaseButton addTarget:self action:@selector(purchaseSet:) forControlEvents:UIControlEventTouchUpInside];
        purchaseButton.setPath = setString;
        [purchaseButton setTitle:[NSString stringWithFormat:NSLocalizedString(@" Unlock Set for %@ Gems ", nil), self.setPrice] forState:UIControlStateNormal];
    } else {
        purchaseButton.hidden = true;
    }
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath animated:NO];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *actionString = NSLocalizedString(@"Use", nil);
    NSString *titleString;
    NSInteger tag = 0;
    if ([self.entityName isEqualToString:@"Customization"]) {
        Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (![customization.purchased boolValue] && [customization.price integerValue] > 0) {
            titleString = [NSString stringWithFormat:NSLocalizedString(@"This item can be purchased for %@ Gems", nil), customization.price];
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Purchase for %@ Gems", nil), customization.price];
            tag = 1;
        }
        self.selectedCustomization = customization;

    } else {
        Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (!gear.owned) {
            titleString = [NSString stringWithFormat:NSLocalizedString(@"This item can be purchased for 2 Gems", nil)];
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Purchase for 2 Gems", nil)];
            tag = 1;
        }
        self.selectedCustomization = gear;
    }
    
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:titleString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:actionString, nil];
    popup.tag = tag;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"set" ascending:YES];
    NSArray *sortDescriptors;
    if ([self.entityName isEqualToString:@"Customization"]) {
        if (self.group) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(purchasable == true || purchased == true || price == 0) && type == %@ && group == %@", self.type, self.group]];
        } else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(purchasable == true || purchased == true || price == 0) && type == %@", self.type]];
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        sortDescriptors = @[typeSortDescriptor, sortDescriptor];
    } else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"set == 'animal' && type == 'headAccessory'"]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
        sortDescriptors = @[typeSortDescriptor, sortDescriptor];
    }
    
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"set" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UICollectionView *collectionView = self.collectionView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeMove:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
    }
}

- (void)configureCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL) animated {
    if ([self.entityName isEqualToString:@"Customization"]) {
        Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/%@.png", [customization getImageNameForUser:self.user]]]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    } else {
        Gear *gear = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/shop_%@.png", gear.key]]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 0:
            if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
                NSString *path;
                if ([self.entityName isEqualToString:@"Customization"]) {
                    [self.sharedManager updateUser:@{self.userKey: [self.selectedCustomization valueForKey:@"name"]} onSuccess:^() {
                        
                    }onError:^() {
                        
                    }];
                } else {
                    path = [self.selectedCustomization valueForKey:@"key"];
                    [self.sharedManager equipObject:[self.selectedCustomization valueForKey:@"key"] withType:self.userKey onSuccess:^{
                    } onError:^{
                        
                    }];
                }
            }
            break;
        case 1:
            if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
                [self.sharedManager unlockPath:[self.selectedCustomization getPath] onSuccess:^() {
                }onError:^() {
                }];
            }
            break;
        case 2:
            if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
                [self.sharedManager unlockPath:self.selectedSetPath onSuccess:^() {
                    [self.collectionView reloadData];
                }onError:^() {
                }];
            }
            break;
        default:
            break;
    }

}

- (void)purchaseSet:(HRPGPurchaseButton *)button {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"This set can be unlocked for %@ Gems", nil), self.setPrice] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Unlock for %@ Gems", nil), self.setPrice], nil];
    popup.tag = 2;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    self.selectedSetPath = button.setPath;
}

-(void)addActivityCounter {
    if (self.activityCounter == 0) {
        self.navigationButton = self.navigationItem.rightBarButtonItem;
        self.activityIndicator = [[HRPGActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        [self.navigationItem setRightBarButtonItem:indicatorButton animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.activityIndicator beginAnimating];
        });
    }
    self.activityCounter++;
}

- (void)removeActivityCounter {
    self.activityCounter--;
    if (self.activityCounter == 0) {
        [self.activityIndicator endAnimating:^() {
            [self.navigationItem setRightBarButtonItem:self.navigationButton animated:NO];
        }];
    } else if (self.activityCounter < 0) {
        self.activityCounter = 0;
    }
}

@end
