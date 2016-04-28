//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGRewardsViewController.h"
#import "Reward.h"
#import "HRPGRewardFormViewController.h"
#import "HRPGNavigationController.h"
#import "HRPGRewardTableViewCell.h"
#import "HRPGGearDetailView.h"
#import "KLCPopup.h"

@interface HRPGRewardsViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property Reward *editedReward;
@property BOOL disableFetchedResultsControllerUpdates;
@property User *user;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate;
@end

@implementation HRPGRewardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.user = self.sharedManager.user;
    self.tutorialIdentifier = @"rewards";

    [self.sharedManager fetchBuyableRewards:nil onError:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"rewards"]) {
        return @{
            @"text" : NSLocalizedString(@"These are your Rewards! Earn gold by completing "
                                        @"real-world Habits, Dailies, and To-Dos. Then spend it "
                                        @"on in-game Rewards or custom real-world Rewards!",
                                        nil)
        };
    }
    return nil;
}

- (void)refresh {
    [self.sharedManager fetchUser:^() {
        [self.sharedManager fetchBuyableRewards:^{
            [self.refreshControl endRefreshing];
        }
            onError:^{
                [self.refreshControl endRefreshing];
                [self.sharedManager displayNetworkError];
            }];
    }
        onError:^() {
            [self.refreshControl endRefreshing];
            [self.sharedManager displayNetworkError];
        }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.sections[section].numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *cellName = @"Cell";
    if (![reward isKindOfClass:[Reward class]]) {
        cellName = @"ImageCell";
    }

    HRPGRewardTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 40.0f;
    float width = self.viewWidth - 127;
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([reward isKindOfClass:[Reward class]]) {
        width = self.viewWidth - 77;
    }
    width = width -
            [[NSString stringWithFormat:@"%ld", (long)[reward.value integerValue]]
                boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{
                              NSFontAttributeName :
                                  [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                          }
                             context:nil]
                .size.width;
    height = height +
             [reward.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{
                                        NSFontAttributeName : [UIFont
                                            preferredFontForTextStyle:UIFontTextStyleHeadline]
                                    }
                                       context:nil]
                 .size.height;
    if ([reward.notes length] > 0) {
        height = height +
                 [reward.notes
                     boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{
                                   NSFontAttributeName :
                                       [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                               }
                                  context:nil]
                     .size.height;
    }
    if ([reward.key isEqualToString:@"armoire"]) {
        height = height + [[self getArmoireFillStatus]
                           boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{
                                        NSFontAttributeName :
                                            [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                        }
                           context:nil].size.height;
    }
    if (height < 87) {
        return 87;
    }
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([reward.type isEqualToString:@"reward"]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([reward isKindOfClass:[Reward class]]) {
            [self.sharedManager deleteReward:(Reward *)reward
                onSuccess:^() {
                }
                onError:^(){

                }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([reward isKindOfClass:[Reward class]]) {
        self.editedReward = (Reward *)reward;
        [self performSegueWithIdentifier:@"FormSegue" sender:self];
    } else {
        NSArray *nibViews =
            [[NSBundle mainBundle] loadNibNamed:@"HRPGGearDetailView" owner:self options:nil];
        HRPGGearDetailView *gearView = [nibViews objectAtIndex:0];
        [gearView configureForReward:reward withGold:[self.user.gold floatValue]];
        gearView.buyAction = ^() {
            if ([reward isKindOfClass:[Reward class]]) {
                [self.sharedManager getReward:reward.key onSuccess:nil onError:nil];
            } else {
                [self.sharedManager buyObject:reward onSuccess:nil onError:nil];
            }
        };
        NSString *imageName;
        if ([reward.key isEqualToString:@"potion"]) {
            imageName = @"shop_potion";
        } else if ([reward.key isEqualToString:@"armoire"]) {
            imageName = @"shop_armoire";
        } else if (![reward.key isEqualToString:@"reward"]) {
            imageName = [NSString stringWithFormat:@"shop_%@", reward.key];
        }
        [self.sharedManager setImage:imageName withFormat:@"png" onView:gearView.imageView];
        [gearView sizeToFit];

        KLCPopup *popup = [KLCPopup popupWithContentView:gearView
                                                showType:KLCPopupShowTypeBounceIn
                                             dismissType:KLCPopupDismissTypeBounceOut
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:NO];
        [popup show];
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    if ([cell.contentView respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell.contentView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaReward"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSString *predicateString = @"type == 'reward' || type == 'potion' ||buyable == true";
    if ([self.user.flags.armoireEnabled boolValue]) {
        predicateString = [predicateString stringByAppendingString:@" || type == 'armoire'"];
    }
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateString]];

    NSSortDescriptor *keyDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSSortDescriptor *orderDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:NO];
    NSSortDescriptor *rewardTypeDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"rewardType" ascending:YES];
    NSArray *sortDescriptors =
        @[ rewardTypeDescriptor, typeDescriptor, orderDescriptor, keyDescriptor ];
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

- (void)configureCell:(HRPGRewardTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell configureForReward:reward withGoldOwned:self.user.gold];

    NSString *imageName;
    if ([reward.key isEqualToString:@"potion"]) {
        imageName = @"shop_potion";
    } else if ([reward.key isEqualToString:@"armoire"]) {
        imageName = @"shop_armoire";
        cell.detailLabel.text = [self getArmoireFillStatus];
    } else if (![reward.key isEqualToString:@"reward"]) {
        imageName = [NSString stringWithFormat:@"shop_%@", reward.key];
    }
    [self.sharedManager setImage:imageName withFormat:@"png" onView:cell.shopImageView];

    [cell onPurchaseTap:^() {
        if ([reward isKindOfClass:[Reward class]]) {
            [self.sharedManager
                getReward:reward.key
                onSuccess:^() {
                    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
                        [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                                atIndexPath:indexPath
                              withAnimation:NO];
                    }
                }
                  onError:nil];
        } else {
            reward.buyable = @NO;
            [self.sharedManager buyObject:reward
                onSuccess:^() {
                    [self.sharedManager fetchBuyableRewards:nil onError:nil];
                    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
                        [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                                atIndexPath:indexPath
                              withAnimation:NO];
                    }
                }
                onError:^() {
                    reward.buyable = @YES;
                    NSError *error;
                    [self.managedObjectContext save:&error];
                }];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FormSegue"]) {
        HRPGNavigationController *destViewController = segue.destinationViewController;
        destViewController.sourceViewController = self;

        HRPGRewardFormViewController *formController =
            (HRPGRewardFormViewController *)destViewController.topViewController;
        if (self.editedReward) {
            formController.editReward = YES;
            formController.reward = self.editedReward;
            self.editedReward = nil;
        }
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGRewardFormViewController *formViewController =
        (HRPGRewardFormViewController *)segue.sourceViewController;
    if (formViewController.editReward) {
        [self.sharedManager updateReward:formViewController.reward onSuccess:nil onError:nil];
    } else {
        [self.sharedManager createReward:formViewController.reward onSuccess:nil onError:nil];
    }
}

- (NSUInteger)leftInArmoire {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear"
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest
        setPredicate:[NSPredicate predicateWithFormat:
                                      @"klass == 'armoire' && (owned == nil || owned == NO)"]];
    NSError *error;
    NSArray *gear = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return gear.count;
}

- (NSString *)getArmoireFillStatus {
    NSUInteger leftInArmoire = [self leftInArmoire];
    if (leftInArmoire > 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Equipment pieces remaining: %d", nil),
                                          leftInArmoire];
    } else {
        return NSLocalizedString(@"The Armoire will have new Equipment in the first week of every "
                                 @"month. Until then, keep clicking for Experience and Food!",
                                 nil);
    }
}

@end
