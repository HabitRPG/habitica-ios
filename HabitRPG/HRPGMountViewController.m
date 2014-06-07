//
//  HRPGPetViewController.m
//  RabbitRPG
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGMountViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "Pet.h"
#import "Egg.h"
#import "HatchingPotion.h"

@interface HRPGMountViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) HRPGManager *sharedManager;
@property (nonatomic) NSArray *eggs;
@property (nonatomic) NSArray *hatchingPotions;
@property (nonatomic) Pet *selectedMount;
@end

@implementation HRPGMountViewController

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
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"HatchingPotion" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.hatchingPotions = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (Egg*) eggWithKey:(NSString*)key {
    for (Egg *egg in self.eggs) {
        if ([egg.key isEqualToString:key]) {
            return egg;
        }
    }
    return nil;
}

- (HatchingPotion*) hatchingPotionWithKey:(NSString*)key {
    for (HatchingPotion *hatchingPotion in self.hatchingPotions) {
        if ([hatchingPotion.key isEqualToString:key]) {
            return hatchingPotion;
        }
    }
    return nil;
}

- (NSString*)niceMountName:(Pet*)mount {
    NSArray *nameParts = [mount.key componentsSeparatedByString:@"-"];
    
    NSString *niceMountName = [self eggWithKey:nameParts[0]].mountText;
    NSString *niceHatchingPotionName = [self hatchingPotionWithKey:nameParts[1]].text;
    
    return [NSString stringWithFormat:@"%@ %@", niceHatchingPotionName, niceMountName];
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
    CGFloat height = 130.0f;
    height = height + [@" " boundingRectWithSize:CGSizeMake(135.0f, MAXFLOAT)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{
                                         NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                                         }
                            context:nil].size.height*2;
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(150.f, height);
    }
    return CGSizeMake(145.0f, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionCell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[headerView viewWithTag:1];
    NSString *sectionName = [[self.fetchedResultsController sections][indexPath.section] name];
    if ([sectionName isEqualToString:@"questPets"]) {
        label.text = NSLocalizedString(@"Quest Mounts", nil);
    } else {
        label.text = NSLocalizedString(@"Base Mounts", nil);
    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BaseCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *equipString = NSLocalizedString(@"Mount", nil);
    Pet *mount = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (!mount.asMount) {
        equipString = nil;
    }

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:[self niceMountName:mount] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:equipString, nil];
    popup.tag = 1;
    self.selectedMount = mount;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
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
    Pet *mount = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    UILabel *label = (UILabel*)[cell viewWithTag:2];
    label.text = [self niceMountName:mount];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    if (mount.asMount) {
        [mount setMountOnImageView:imageView];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.alpha = 1;
    } else {
        [imageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/PixelPaw.png"]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.alpha = 0.3f;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
        [self.sharedManager equipObject:self.selectedMount.key withType:@"mount" onSuccess:^() {
        }onError:^() {
        }];
    }
}

@end
