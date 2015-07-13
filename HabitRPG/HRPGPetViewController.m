//
//  HRPGPetViewController.m
//  Habitica
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
#import "HRPGNavigationController.h"
#import "HRPGActivityIndicator.h"
#import "HRPGTopHeaderNavigationController.h"
#import <pop/POP.h>

@interface HRPGPetViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSArray *eggs;
@property (nonatomic) NSArray *hatchingPotions;
@property (nonatomic) Pet *selectedPet;
@property UIBarButtonItem *navigationButton;
@property HRPGActivityIndicator *activityIndicator;
@property CGSize screenSize;
@property NSString *equippedPetName;
@end

@implementation HRPGPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.equippedPetName = [self.sharedManager getUser].currentPet;

    self.screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (self.petColor) {
        self.navigationItem.title = self.petColor;
    } else {
        self.navigationItem.title = self.petName;
    }
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Egg" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.eggs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"HatchingPotion" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.hatchingPotions = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
    [self.collectionView setContentInset:UIEdgeInsetsMake([navigationController getContentOffset],0,0,0)];
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([navigationController getContentOffset],0,0,0);
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
                                              context:nil].size.height*3;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return CGSizeMake(self.screenSize.width/4-15, height);
    }
    return CGSizeMake(self.screenSize.width/3-10, height);
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
    [self configureCell:cell atIndexPath:indexPath animated:NO];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *equipString = NSLocalizedString(@"Equip", nil);
    NSString *feedString = NSLocalizedString(@"Feed", nil);
    Pet *pet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!pet.trained || [pet.trained integerValue] == -1) {
        equipString = nil;
    } else if ([self.equippedPetName isEqualToString:pet.key]) {
        equipString = NSLocalizedString(@"Unequip", nil);
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    if (self.petName) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key contains[cd] %@ && type = %@", self.petName, self.petType]];
    } else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key contains[cd] %@ && type = %@", self.petColor, self.petType]];
    }
    
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *sortDescriptors = @[typeSortDescriptor, sortDescriptor];
    
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
            [self configureCell:[collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath animated:YES];
            break;
            
        case NSFetchedResultsChangeMove:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
    }
}

- (void)configureCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL) animated {
    Pet *pet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    UIProgressView *progressView = (UIProgressView*)[cell viewWithTag:2];
    UILabel *label = (UILabel*)[cell viewWithTag:3];
    label.text = [self nicePetName:pet];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    imageView.alpha = 1;
    if (pet.trained) {
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/Pet-%@.png", pet.key]]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        if ([pet.trained integerValue] == -1) {
            imageView.alpha = 0.3f;
        }
    } else {
        [imageView setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/PixelPaw.png"]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        imageView.alpha = 0.3f;
    }
    
    progressView.hidden = YES;
    if (![pet.key hasPrefix:@"Egg"]) {
        if (pet.trained && [pet.trained integerValue] != -1 && !pet.asMount) {
            progressView.hidden = NO;
            if (animated) {
                POPBasicAnimation *scaleAnim = [POPBasicAnimation easeInEaseOutAnimation];
                scaleAnim.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
                scaleAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1.1, 1.3)];
                scaleAnim.duration = 0.2;
                scaleAnim.completionBlock = ^(POPAnimation *anim, BOOL completed) {
                    POPSpringAnimation *unScaleAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
                    unScaleAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
                    unScaleAnim.springBounciness = 13;
                    unScaleAnim.springSpeed = 3;
                    [progressView pop_addAnimation:unScaleAnim forKey:@"scaleAnimation"];
                };
                
                [progressView pop_addAnimation:scaleAnim forKey:@"scaleAnimation"];
                
                [UIView animateWithDuration:0.3 animations:^() {
                    progressView.progress = [pet.trained floatValue] / 50;
                }];
            } else {
                progressView.progress = [pet.trained floatValue] / 50;
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
        [self.sharedManager equipObject:self.selectedPet.key withType:@"pet" onSuccess:^() {
            if ([self.equippedPetName isEqualToString:self.selectedPet.key]) {
                self.equippedPetName = nil;
            } else {
                self.equippedPetName = self.selectedPet.key;
            }
        }onError:^() {
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
    [self.sharedManager feedPet:self.selectedPet.key withFood:food.key onSuccess:^() {
    }onError:^() {
    }];
}



@end
