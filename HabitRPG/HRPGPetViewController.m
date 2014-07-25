//
//  HRPGPetViewController.m
//  RabbitRPG
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGPetViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGFeedViewController.h"
#import "HRPGManager.h"
#import "Pet.h"
#import "Egg.h"
#import "HatchingPotion.h"
#import "HRPGBallActivityIndicator.h"

@interface HRPGPetViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) HRPGManager *sharedManager;
@property (nonatomic) NSArray *eggs;
@property (nonatomic) NSArray *hatchingPotions;
@property (nonatomic) Pet *selectedPet;
@property NSInteger activityCounter;
@property UIBarButtonItem *navigationButton;
@end

@implementation HRPGPetViewController

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
    
    self.navigationItem.title = self.petName;
    
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

- (NSString*) eggWithKey:(NSString*)key {
    for (Egg *egg in self.eggs) {
        if ([egg.key isEqualToString:key]) {
            return egg.text;
        }
    }
    return key;
}

- (NSString*) hatchingPotionWithKey:(NSString*)key {
    for (HatchingPotion *hatchingPotion in self.hatchingPotions) {
        if ([hatchingPotion.key isEqualToString:key]) {
            return hatchingPotion.text;
        }
    }
    return key;
}

- (NSString*)nicePetName:(Pet*)pet {
    NSArray *nameParts = [pet.key componentsSeparatedByString:@"-"];
    
    NSString *nicePetName = [self eggWithKey:nameParts[0]];
    NSString *niceHatchingPotionName = [self hatchingPotionWithKey:nameParts[1]];
    
    return [NSString stringWithFormat:@"%@ %@", niceHatchingPotionName, nicePetName];
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
    CGFloat height = 121.0f;
    height = height + [@" " boundingRectWithSize:CGSizeMake(90.0f, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                                                        }
                                              context:nil].size.height*2;
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(120.0f, height);
    }
    return CGSizeMake(100.0f, height);
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BaseCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *equipString = NSLocalizedString(@"Equip", nil);
    NSString *feedString = NSLocalizedString(@"Feed", nil);
    Pet *pet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!pet.trained || [pet.trained integerValue] == -1) {
        equipString = nil;
    }
    if (pet.asMount) {
        feedString = nil;
    }

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:[self nicePetName:pet] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:equipString, feedString, nil];
    popup.tag = 1;
    self.selectedPet = pet;
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
    if (self.petType) {
        NSString *completeName = [NSString stringWithFormat:@"%@-%@", self.petName, self.petType];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key = %@", completeName]];
    } else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key contains[cd] %@", self.petName]];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *sortDescriptors = @[typeSortDescriptor, sortDescriptor];
    
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
    Pet *pet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    UIProgressView *progressView = (UIProgressView*)[cell viewWithTag:2];
    UILabel *label = (UILabel*)[cell viewWithTag:3];
    label.text = [self nicePetName:pet];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    imageView.alpha = 1;
    if (pet.trained) {
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/Pet-%@.png", pet.key]]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        if ([pet.trained integerValue] == -1) {
            imageView.alpha = 0.3f;
        }
    } else {
        [imageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/PixelPaw.png"]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        imageView.alpha = 0.3f;
    }
    
    progressView.hidden = YES;
    if (pet.trained && [pet.trained integerValue] != -1 && !pet.asMount) {
        progressView.progress = [pet.trained floatValue] / 100;
        progressView.hidden = NO;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
        [self addActivityCounter];
        [self.sharedManager equipObject:self.selectedPet.key withType:@"pet" onSuccess:^() {
            [self removeActivityCounter];
        }onError:^() {
            [self removeActivityCounter];
        }];
    } else if (actionSheet.numberOfButtons > 2 && buttonIndex == 1) {
        [self performSegueWithIdentifier:@"FeedSegue" sender:self];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGFeedViewController *feedController = (HRPGFeedViewController*)[segue sourceViewController];
    Food *food = feedController.selectedFood;
    [self addActivityCounter];
    [self.sharedManager feedPet:self.selectedPet.key withFood:food.key onSuccess:^() {
        [self removeActivityCounter];
    }onError:^() {
        [self removeActivityCounter];
    }];
}

-(void)addActivityCounter {
    if (self.activityCounter == 0) {
        self.navigationButton = self.navigationItem.rightBarButtonItem;
        //HRPGRoundProgressView *indicator = [[HRPGRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        //indicator.strokeWidth = 2;
        //[indicator beginAnimating];
        HRPGBallActivityIndicator *indicator = [[HRPGBallActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [indicator beginAnimating];
        UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:indicator];
        [self.navigationItem setRightBarButtonItem:indicatorButton animated:NO];
    }
    self.activityCounter++;
}

- (void)removeActivityCounter {
    self.activityCounter--;
    if (self.activityCounter == 0) {
        [self.navigationItem setRightBarButtonItem:self.navigationButton animated:NO];
    } else if (self.activityCounter < 0) {
        self.activityCounter = 0;
    }
}

@end
