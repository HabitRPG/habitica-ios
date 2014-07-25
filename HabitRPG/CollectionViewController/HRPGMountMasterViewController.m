//
//  HRPGPetViewController.m
//  RabbitRPG
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGMountMasterViewController.h"
#import "HRPGMountViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGFeedViewController.h"
#import "HRPGManager.h"
#import "Pet.h"
#import "Egg.h"
#import "HatchingPotion.h"
#import "HRPGBallActivityIndicator.h"

@interface HRPGMountMasterViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) HRPGManager *sharedManager;
@property (nonatomic) NSArray *eggs;
@property (nonatomic) NSArray *hatchingPotions;
@property (nonatomic) NSString *selectedMount;
@property (nonatomic) NSString *selectedType;
@property (nonatomic) NSArray *sortedPets;
@property NSInteger activityCounter;
@property UIBarButtonItem *navigationButton;
@end

@implementation HRPGMountMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = self.sharedManager.getManagedObjectContext;
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Egg" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.eggs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (Egg*) eggWithKey:(NSString*)key {
    for (Egg *egg in self.eggs) {
        if ([egg.key isEqualToString:key]) {
            return egg;
        }
    }
    return nil;
}

- (NSString*) eggNameWithKey:(NSString*)key {
    for (Egg *egg in self.eggs) {
        if ([egg.key isEqualToString:key]) {
            return egg.mountText;
        }
    }
    return key;
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sortedPets[section] count];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *petArray = self.sortedPets[indexPath.section][indexPath.item];
    Pet *namePet = [petArray firstObject];
    int mounted = 0;
    for (Pet *pet in petArray) {
        if (pet.asMount) {
            mounted++;
        }
    }
    if (mounted > 0) {
        self.selectedMount = [namePet.key componentsSeparatedByString:@"-"][0];
        if ([namePet.type isEqualToString:@" "]) {
            self.selectedType = [namePet.key componentsSeparatedByString:@"-"][1];
        } else {
            self.selectedType = nil;
        }
        return YES;
    }
    return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 136.0f;
    height = height + [@" " boundingRectWithSize:CGSizeMake(140.0f, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{
                                                   NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                                                   }
                                         context:nil].size.height*2;
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(140.0f, height);
    }
    return CGSizeMake(140.0f, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionCell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[headerView viewWithTag:1];
    NSString *sectionName = [[self.fetchedResultsController sections][indexPath.section] name];
    if ([sectionName isEqualToString:@"questPets"]) {
        label.text = NSLocalizedString(@"Quest Pets", nil);
    } else if ([sectionName isEqualToString:@" "]) {
        label.text = NSLocalizedString(@"Special Pets", nil);
    } else {
        label.text = NSLocalizedString(@"Base Pets", nil);
    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (NSArray*)sortedPets {
    if (_sortedPets) {
        return _sortedPets;
    }
    
    NSMutableArray *newSortedPets = [NSMutableArray array];
    for (id <NSFetchedResultsSectionInfo> sectionInfo in self.fetchedResultsController.sections) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [newSortedPets addObject:sectionArray];
        for (Pet *pet in [sectionInfo objects]) {
            NSArray *nameParts = [pet.key componentsSeparatedByString:@"-"];
            if ([nameParts[0] isEqualToString:@"Egg"] || [nameParts[0] isEqualToString:@"Turkey"]) {
                continue;
            }
            NSMutableArray *petArray;
            for (NSMutableArray *oldPetArray in sectionArray) {
                if (oldPetArray) {
                    Pet *oldPet = [oldPetArray firstObject];
                    if ([nameParts[0] isEqualToString:[oldPet.key componentsSeparatedByString:@"-"][0]]) {
                        petArray = oldPetArray;
                        break;
                    }
                }
            }
            if (!petArray) {
                petArray = [NSMutableArray array];
                [sectionArray addObject:petArray];
            }
            [petArray addObject:pet];
        }
    }
    _sortedPets = newSortedPets;
    return newSortedPets;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *sortDescriptors = @[typeSortDescriptor, sortDescriptor];
    
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
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

- (void)configureCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *petArray = self.sortedPets[indexPath.section][indexPath.item];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
    UILabel *progressLabel = (UILabel*)[cell viewWithTag:3];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    progressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    Pet *namePet = [petArray firstObject];
    NSString *key = [namePet.key componentsSeparatedByString:@"-"][0];
    label.text = [self eggNameWithKey:key];
    int mounted = 0;
    
    for (Pet *pet in petArray) {
        if (pet.asMount) {
            mounted++;
        }
    }
    
    if (mounted > 0) {
        [namePet setMountOnImageView:imageView];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.alpha = 1;
    } else {
        [imageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/PixelPaw.png"]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.alpha = 0.3f;
    }
    
    progressLabel.text = [NSString stringWithFormat:@"%d/%lu", mounted, (unsigned long)[petArray count]];
}

- (void)removeActivityCounter {
    self.activityCounter--;
    if (self.activityCounter == 0) {
        [self.navigationItem setRightBarButtonItem:self.navigationButton animated:NO];
    } else if (self.activityCounter < 0) {
        self.activityCounter = 0;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"PetSegue"]) {
        HRPGMountViewController *petController = (HRPGMountViewController*)segue.destinationViewController;
        petController.mountName = self.selectedMount;
        petController.mountType = self.selectedType;
    }
}

@end
