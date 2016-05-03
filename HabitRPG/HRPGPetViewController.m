//
//  HRPGPetViewController.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGPetViewController.h"
#import <pop/POP.h>
#import "Egg.h"
#import "HRPGFeedViewController.h"
#import "HatchingPotion.h"
#import "UIViewcontroller+TutorialSteps.h"

@interface HRPGPetViewController ()
@property(nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic) NSArray *eggs;
@property(nonatomic) NSArray *hatchingPotions;
@property(nonatomic) Pet *selectedPet;
@property UIBarButtonItem *navigationButton;
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
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Egg" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.eggs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"HatchingPotion"
                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.hatchingPotions =
        [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self displayTutorialStep:self.sharedManager];
}

- (Egg *)eggWithKey:(NSString *)key {
    for (Egg *egg in self.eggs) {
        if ([egg.key isEqualToString:key]) {
            return egg;
        }
    }
    return nil;
}

- (HatchingPotion *)hatchingPotionWithKey:(NSString *)key {
    for (HatchingPotion *hatchingPotion in self.hatchingPotions) {
        if ([hatchingPotion.key isEqualToString:key]) {
            return hatchingPotion;
        }
    }
    return nil;
}

- (NSString *)niceMountName:(Pet *)mount {
    NSArray *nameParts = [mount.key componentsSeparatedByString:@"-"];

    NSString *niceMountName = [self eggWithKey:nameParts[0]].mountText;
    if (!niceMountName) {
        niceMountName = nameParts[0];
    }
    NSString *niceHatchingPotionName = [self hatchingPotionWithKey:nameParts[1]].text;
    if (!niceHatchingPotionName) {
        niceHatchingPotionName = nameParts[1];
    }
    return [NSString stringWithFormat:@"%@ %@", niceHatchingPotionName, niceMountName];
}

- (NSString *)nicePetName:(Pet *)pet {
    NSArray *nameParts = [pet.key componentsSeparatedByString:@"-"];

    NSString *nicePetName = [self eggWithKey:nameParts[0]].text;
    if (!nicePetName) {
        nicePetName = nameParts[0];
    }
    NSString *niceHatchingPotionName = [self hatchingPotionWithKey:nameParts[1]].text;
    if (!niceHatchingPotionName) {
        niceHatchingPotionName = nameParts[1];
    }
    return [NSString stringWithFormat:@"%@ %@", niceHatchingPotionName, nicePetName];
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
    CGFloat height = 121.0f;
    height = height +
             [@" " boundingRectWithSize:CGSizeMake(90.0f, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{
                                 NSFontAttributeName :
                                     [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                             }
                                context:nil]
                     .size.height *
                 3;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return CGSizeMake(self.screenSize.width / 4 - 15, height);
    }
    return CGSizeMake(self.screenSize.width / 3 - 10, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:@"SectionCell"
                                                  forIndexPath:indexPath];
    UILabel *label = [headerView viewWithTag:1];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"BaseCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath animated:NO];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *equipString = NSLocalizedString(@"Equip", nil);
    NSString *feedString = NSLocalizedString(@"Feed", nil);
    Pet *pet = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (!pet.trained || [pet.trained integerValue] == -1) {
        equipString = nil;
    } else if ([self.equippedPetName isEqualToString:pet.key]) {
        equipString = NSLocalizedString(@"Unequip", nil);
    }
    if ((pet.asMount) || ([pet.type isEqualToString:@" "])) {
        feedString = nil;
    }

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:[self nicePetName:pet]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:equipString, feedString, nil];
    popup.tag = 1;
    self.selectedPet = pet;

    // get the selected cell so that the popup can be displayed near it on the iPad
    UICollectionViewCell *selectedCell =
        [self collectionView:collectionView cellForItemAtIndexPath:indexPath];

    CGRect rectIPad = CGRectMake(selectedCell.frame.origin.x,
                                 selectedCell.frame.origin.y + selectedCell.frame.size.height,
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
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    if (self.petName) {
        [fetchRequest
            setPredicate:[NSPredicate
                             predicateWithFormat:@"key BEGINSWITH[cd] %@ && type = %@",
                                                 [self.petName stringByAppendingString:@"-"],
                                                 self.petType]];
    } else {
        [fetchRequest
            setPredicate:[NSPredicate
                             predicateWithFormat:@"key ENDSWITH[cd] %@ && type = %@",
                                                 [@"-" stringByAppendingString:self.petColor],
                                                 self.petType]];
    }

    NSSortDescriptor *typeSortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *sortDescriptors = @[ typeSortDescriptor, sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
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
            [self configureCell:[collectionView cellForItemAtIndexPath:indexPath]
                    atIndexPath:indexPath
                       animated:YES];
            break;

        case NSFetchedResultsChangeMove:
            if (indexPath.item != newIndexPath.item) {
                [collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
                [collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            } else {
                [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            }
            break;
    }
}

- (void)configureCell:(UICollectionViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
             animated:(BOOL)animated {
    Pet *pet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:1];
    UIProgressView *progressView = [cell viewWithTag:2];
    UILabel *label = [cell viewWithTag:3];
    if (!pet.nicePetName) {
        pet.nicePetName = [self nicePetName:pet];
    }
    label.text = pet.nicePetName;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    imageView.alpha = 1;
    if ([pet.trained boolValue]) {
        NSString *format = @"png";
        if ([pet.key isEqualToString:@"Wolf-Cerberus"]) {
            format = @"gif";
        }
        [self.sharedManager setImage:[NSString stringWithFormat:@"Pet-%@", pet.key]
                          withFormat:format
                              onView:imageView];

        if ([pet.trained integerValue] == -1) {
            imageView.alpha = 0.3f;
        }
    } else {
        [self.sharedManager setImage:@"PixelPaw" withFormat:@"png" onView:imageView];
        imageView.alpha = 0.3f;
    }

    progressView.hidden = YES;
    if (!([pet.key hasPrefix:@"Egg"] || [pet.type isEqualToString:@" "])) {
        if (pet.trained && [pet.trained integerValue] != -1 && !pet.asMount) {
            progressView.hidden = NO;
            if (animated) {
                POPBasicAnimation *scaleAnim = [POPBasicAnimation easeInEaseOutAnimation];
                scaleAnim.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
                scaleAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1.1, 1.3)];
                scaleAnim.duration = 0.2;
                scaleAnim.completionBlock = ^(POPAnimation *anim, BOOL completed) {
                    POPSpringAnimation *unScaleAnim =
                        [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
                    unScaleAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
                    unScaleAnim.springBounciness = 13;
                    unScaleAnim.springSpeed = 3;
                    [progressView pop_addAnimation:unScaleAnim forKey:@"scaleAnimation"];
                };

                [progressView pop_addAnimation:scaleAnim forKey:@"scaleAnimation"];

                [UIView animateWithDuration:0.3
                                 animations:^() {
                                     progressView.progress = [pet.trained floatValue] / 50;
                                 }];
            } else {
                progressView.progress = [pet.trained floatValue] / 50;
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
        [self.sharedManager equipObject:self.selectedPet.key
            withType:@"pet"
            onSuccess:^() {
                if ([self.equippedPetName isEqualToString:self.selectedPet.key]) {
                    self.equippedPetName = nil;
                } else {
                    self.equippedPetName = self.selectedPet.key;
                }
            }
            onError:^(){
            }];
    } else if (actionSheet.numberOfButtons > 2 && buttonIndex == 1) {
        [self performSegueWithIdentifier:@"FeedSegue" sender:self];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGFeedViewController *feedController = [segue sourceViewController];
    Food *food = feedController.selectedFood;
    self.selectedPet.niceMountName = [self niceMountName:self.selectedPet];
    [self.sharedManager feedPet:self.selectedPet
        withFood:food
        onSuccess:^() {
        }
        onError:^(){
        }];
}

@end
