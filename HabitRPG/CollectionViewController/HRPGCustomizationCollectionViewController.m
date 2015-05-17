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
#import "HRPGPurchaseButton.h"

@interface HRPGCustomizationCollectionViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) HRPGManager *sharedManager;
@property NSInteger activityCounter;
@property UIBarButtonItem *navigationButton;
@property HRPGActivityIndicator *activityIndicator;
@property CGSize screenSize;
@property Customization *selectedCustomization;
@property NSString *selectedSetPath;
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
    return CGSizeMake((self.screenSize.width-30)/4, 75.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionCell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[headerView viewWithTag:1];
    label.text = [[[[[self.fetchedResultsController sections][indexPath.section] name] stringByReplacingOccurrencesOfString:@"Shirts" withString:@""] stringByReplacingOccurrencesOfString:@"Skins" withString:@""] uppercaseString];
    HRPGPurchaseButton *purchaseButton = (HRPGPurchaseButton*)[headerView viewWithTag:2];
    BOOL purchasable = NO;
    NSString *setString = @"";
    for (Customization *customization in [[self.fetchedResultsController sections][indexPath.section] objects]) {
        if ([customization.purchasable boolValue] && ![customization.purchased boolValue]){
            purchasable = YES;
        }
        setString = [setString stringByAppendingFormat:@"%@,", [customization getPath]];
    }
    setString = [setString stringByPaddingToLength:setString.length-1 withString:nil startingAtIndex:0];
    if (purchasable) {
        purchaseButton.hidden = false;
        [purchaseButton addTarget:self action:@selector(purchaseSet:) forControlEvents:UIControlEventTouchUpInside];
        purchaseButton.setPath = setString;
    } else {
        purchaseButton.hidden = true;
    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *cellName;
    if ([customization.purchased boolValue] || [customization.price integerValue] == 0) {
        cellName = @"Cell";
    } else {
        cellName = @"LockedCell";
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath animated:NO];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *actionString = NSLocalizedString(@"Use", nil);
    NSString *titleString;
    NSInteger tag = 0;
    Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (![customization.purchased boolValue] && [customization.price integerValue] > 0) {
        titleString = [NSString stringWithFormat:NSLocalizedString(@"This item can be purchased for %@ Gems", nil), customization.price];
        actionString = [NSString stringWithFormat:NSLocalizedString(@"Purchase for %@ Gems", nil), customization.price];
        tag = 1;
    }
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:titleString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:actionString, nil];
    popup.tag = tag;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    self.selectedCustomization = customization;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    if (self.group) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(purchasable == true || purchased == true || price == 0) && type == %@ && group == %@", self.type, self.group]];
    } else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(purchasable == true || purchased == true || price == 0) && type == %@", self.type]];
    }
    
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"set" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[typeSortDescriptor, sortDescriptor];
    
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
    Customization *customization = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/%@.png", [customization getImageNameForUser:self.user]]]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 0:
            if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
                [self.sharedManager updateUser:@{self.userKey: self.selectedCustomization.name} onSuccess:^() {
                    
                }onError:^() {
                    
                }];
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
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This set can be purchased for 5 Gems", nil) delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Purchase for 5 Gems", nil), nil];
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
