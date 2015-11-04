//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGRewardsViewController.h"
#import "HRPGAppDelegate.h"
#import <PDKeychainBindings.h>
#import "Gear.h"
#import "User.h"
#import "Reward.h"
#import <NSString+Emoji.h>
#import "HRPGRewardFormViewController.h"
#import <POPSpringAnimation.h>
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGRewardsViewController

User *user;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    user = self.sharedManager.user;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadAllData:)
     name:@"shouldReloadAllData"
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(startClearing:)
     name:@"startClearingData"
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(finishedClearing:)
     name:@"finishedClearingData"
     object:nil];
    self.tutorialIdentifier = @"rewards";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"rewards"]) {
        return @{@"text": NSLocalizedString(@"These are your Rewards! Earn gold by completing real-world Habits, Dailies, and To-Dos. Then spend it on in-game Rewards or custom real-world Rewards!", nil)};
    }
    return nil;
}

- (void)refresh {
    [self.sharedManager fetchUser:^() {
        [self.refreshControl endRefreshing];
        self.filteredData = nil;
        [self.tableView reloadData];
    }                     onError:^() {
        [self.refreshControl endRefreshing];
        [self.sharedManager displayNetworkError];
    }];
}

- (void)reloadAllData:(NSNotification *)notification {
    self.filteredData = nil;
    [self.tableView reloadData];
}

- (void)startClearing:(NSNotification *)notification {
    self.disableFetchedResultsControllerUpdates = YES;
}

- (void)finishedClearing:(NSNotification *)notification {
    self.disableFetchedResultsControllerUpdates = NO;
    self.filteredData = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.filteredData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self getRewardAtIndexPath:indexPath];
    NSString *cellName = @"Cell";
    if (![reward isKindOfClass:[Reward class]]) {
        cellName = @"ImageCell";
    }
    
    HRPGRewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 40.0f;
    float width = self.viewWidth-127;
    MetaReward *reward = [self getRewardAtIndexPath:indexPath];
    if ([reward isKindOfClass:[Reward class]]) {
        width = self.viewWidth-77;
    }
    width = width - [[NSString stringWithFormat:@"%ld", (long) [reward.value integerValue]] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                      attributes:@{
                                                                                                              NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                                                                      }
                                                                                                         context:nil].size.width;
    height = height + [reward.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                     NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                             }
                                                context:nil].size.height;
    if ([reward.notes length] > 0) {
        height = height + [reward.notes boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                                  }
                                                     context:nil].size.height;
    }
    if (height < 87) {
        return 87;
    }
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self getRewardAtIndexPath:indexPath];
    if ([reward.type isEqualToString:@"reward"]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MetaReward *reward = [self getRewardAtIndexPath:indexPath];
        if ([reward isKindOfClass:[Reward class]]) {
            [self.sharedManager deleteReward:(Reward*)reward onSuccess:^() {
            } onError:^() {
            
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MetaReward *reward = [self getRewardAtIndexPath:indexPath];
    if ([reward isKindOfClass:[Reward class]]) {
        self.editedReward = (Reward *)reward;
        [self performSegueWithIdentifier:@"FormSegue" sender:self];
    } else {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"HRPGGearDetailView" owner:self options:nil];
        HRPGGearDetailView *gearView = [nibViews objectAtIndex:0];
        [gearView configureForReward:reward withGold:[user.gold floatValue]];
        gearView.buyAction = ^() {
            if ([reward isKindOfClass:[Reward class]]) {
                [self.sharedManager getReward:reward.key onSuccess:nil onError:nil];
            } else {
                [self.sharedManager buyObject:reward onSuccess:nil onError:nil];
            }
        };
        [gearView sizeToFit];
        
        KLCPopup* popup = [KLCPopup popupWithContentView:gearView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [popup show];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (MetaReward *)getRewardAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section < [self.filteredData count]) {
        if (indexPath.item < [self.filteredData[indexPath.section] count]) {
            return self.filteredData[indexPath.section][indexPath.item];
        }
    }
    return nil;
}

- (NSArray *)filteredData {
    if (_filteredData != nil) {
        return _filteredData;
    }
    //The filtering wasn't possible with predicates, so everything is fetched and filtered here
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *inGameItemsArray = [[NSMutableArray alloc] init];
    NSMutableArray *customRewardsArray = [[NSMutableArray alloc] init];
    NSString *userClass = [user getCleanedClassName];
    if (userClass == nil) {
        userClass = @"warrior";
    }
    for (Reward *reward in self.fetchedResultsController.fetchedObjects) {
            if ([reward isKindOfClass:[Gear class]]) {
                Gear *gear = (Gear*)reward;
                if (gear.owned) {
                    continue;
                }
                if ([gear.key rangeOfString:@"_special_1"].location != NSNotFound) {
                    //filter the special contributer gear
                    if ([gear.type isEqualToString:@"armor"] && [user.contributorLevel intValue] < 2) {
                        continue;
                    } else if ([gear.type isEqualToString:@"head"] && [user.contributorLevel intValue] < 3) {
                        continue;
                    } else if ([gear.type isEqualToString:@"weapon"] && [user.contributorLevel intValue] < 4) {
                        continue;
                    } else if ([gear.type isEqualToString:@"shield"] && [user.contributorLevel intValue] < 5) {
                        continue;
                    }
                }
                if (!([userClass isEqualToString:[gear getCleanedClassName]] || [userClass isEqualToString:gear.specialClass])) {
                    //filter gear that is not the right class
                    continue;
                }
                if (gear.eventStart) {
                    //filter event gear
                    NSDate *today = [NSDate date];
                    if (!([today compare:gear.eventStart] == NSOrderedDescending && [today compare:gear.eventEnd] == NSOrderedAscending)) {
                        continue;
                    }
                }
                BOOL shouldAdd = YES;
                for (Reward *oldReward in inGameItemsArray) {
                    if ([oldReward isKindOfClass:[Gear class]] && [[oldReward.key substringToIndex:oldReward.key.length-2] isEqualToString:[gear.key substringToIndex:gear.key.length-2]]) {
                        Gear *lastGear = (Gear*)[inGameItemsArray lastObject];
                        if (gear.index && lastGear.index && ![gear.klass isEqualToString:@"special"]) {
                            if (![[lastGear getCleanedClassName] isEqualToString:@"special"] && lastGear.index < gear.index && [lastGear.type isEqualToString:gear.type]) {
                                //filter gear with lower level
                                shouldAdd = NO;
                            } else if ([[inGameItemsArray lastObject] index] > gear.index && [lastGear.type isEqualToString:gear.type]) {
                                //remove last object if current one is of higher level
                                [inGameItemsArray removeObject:oldReward];
                            }
                        }
                        break;
                    }
                }
                if (shouldAdd) {
                    [inGameItemsArray addObject:reward];
                }
            } else {
                if ([reward isKindOfClass:[Reward class]]) {
                    [customRewardsArray addObject:reward];
                } else {
                    if ([reward.key isEqualToString:@"armoire"]) {
                        if (![user.armoireEnabled boolValue]) {
                            continue;
                        }
                    }
                    [inGameItemsArray insertObject:reward atIndex:0];
                }
        }
    }
    
    if ([inGameItemsArray count] > 0) {
        [array addObject:inGameItemsArray];
    }
    if ([customRewardsArray count] > 0) {
        [array addObject:customRewardsArray];
    }
    
    self.filteredData = array;
    
    return _filteredData;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaReward" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *keyDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[typeDescriptor, orderDescriptor, keyDescriptor];
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
    if (self.disableFetchedResultsControllerUpdates) {
        return;
    }
    self.filteredData = nil;
    [self.tableView reloadData];
    return;
}

- (void)configureCell:(HRPGRewardTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    MetaReward *reward = [self getRewardAtIndexPath:indexPath];
    
    [cell configureForReward:reward withGoldOwned:user.gold];
    
    [cell onPurchaseTap:^() {
        if ([reward isKindOfClass:[Reward class]]) {
            [self.sharedManager getReward:reward.key onSuccess:^() {
                for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
                    [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:NO];
                }
            } onError:nil];
        } else {
            [self.sharedManager buyObject:reward onSuccess:^() {
                for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
                    [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:NO];
                }
            } onError:nil];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FormSegue"]) {
        HRPGNavigationController *destViewController = segue.destinationViewController;
        destViewController.sourceViewController = self;
        
        HRPGRewardFormViewController *formController = (HRPGRewardFormViewController *) destViewController.topViewController;
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
    HRPGRewardFormViewController *formViewController = (HRPGRewardFormViewController *) segue.sourceViewController;
    if (formViewController.editReward) {
        [self.sharedManager updateReward:formViewController.reward onSuccess:nil onError:nil];
    } else {
        [self.sharedManager createReward:formViewController.reward onSuccess:nil onError:nil];
    }
}

@end
