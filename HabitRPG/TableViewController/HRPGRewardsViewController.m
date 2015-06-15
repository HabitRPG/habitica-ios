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
#import <SDWebImage/UIImageView+WebCache.h>
#import "HRPGRewardFormViewController.h"
#import <POPSpringAnimation.h>
#import "HRPGNavigationController.h"

@interface HRPGRewardsViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property Reward *editedReward;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGRewardsViewController

User *user;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    user = [self.sharedManager getUser];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadAllData:)
     name:@"shouldReloadAllData"
     object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)refresh {
    [self.sharedManager fetchUser:^() {
        [self.refreshControl endRefreshing];
        _filteredData = nil;
        [self.tableView reloadData];
    }                     onError:^() {
        [self.refreshControl endRefreshing];
        [self.sharedManager displayNetworkError];
    }];
}

- (void)reloadAllData:(NSNotification *)notification {
    _filteredData = nil;
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
    UITableViewCell *cell;
    MetaReward *reward = self.filteredData[indexPath.section][indexPath.item];

    if ([reward isKindOfClass:[Reward class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongCellPress:)];
        [cell addGestureRecognizer:longPressGesture];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        for (UIGestureRecognizer *gestureRecognizer in [cell gestureRecognizers]) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [cell removeGestureRecognizer:gestureRecognizer];
                break;
            }
        };
    }
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 22.0f;
    float width = self.screenWidth-111;
    MetaReward *reward = self.filteredData[indexPath.section][indexPath.item];
    if ([reward isKindOfClass:[Reward class]]) {
        width = self.screenWidth-50;
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
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = self.filteredData[indexPath.section][indexPath.item];
    if ([reward.type isEqualToString:@"reward"]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Reward *reward = self.filteredData[indexPath.section][indexPath.item];
        [self.sharedManager deleteReward:reward onSuccess:^() {
        } onError:^() {
            
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = self.filteredData[indexPath.section][indexPath.item];
    if ([user.gold integerValue] < [reward.value integerValue]) {
        return;
    }
    [self addActivityCounter];
    if ([reward isKindOfClass:[Reward class]]) {
        [self.sharedManager getReward:reward.key onSuccess:^() {
            [self removeActivityCounter];
        }                     onError:^() {
            [self removeActivityCounter];
        }];
    } else {
        [self.sharedManager buyObject:reward onSuccess:^() {
            [self removeActivityCounter];
        }                     onError:^() {
            [self removeActivityCounter];
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (NSArray *)filteredData {
    if (_filteredData != nil) {
        return _filteredData;
    }
    //The filtering wasn't possible with predicates, so everything is fetched and filtered here
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *inGameItemsArray = [[NSMutableArray alloc] init];
    NSMutableArray *customRewardsArray = [[NSMutableArray alloc] init];
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
                } else if (!([gear.klass isEqualToString:user.dirtyClass] || [gear.specialClass isEqualToString:user.dirtyClass])) {
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
                if ([[inGameItemsArray lastObject] isKindOfClass:[Gear class]]) {
                    if (gear.index && [[inGameItemsArray lastObject] index] && ![gear.klass isEqualToString:@"special"]) {
                        if (![[(Gear*)[inGameItemsArray lastObject] getCleanedClassName] isEqualToString:@"special"] && [[inGameItemsArray lastObject] index] < gear.index) {
                            //filter gear with lower level
                            continue;
                        } else if ([[inGameItemsArray lastObject] index] > gear.index) {
                            //remove last object if current one is of higher level
                            [inGameItemsArray removeLastObject];
                        }
                    }
                }
                [inGameItemsArray addObject:reward];
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
    _filteredData = nil;
    [self.tableView reloadData];
    return;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    MetaReward *reward = self.filteredData[indexPath.section][indexPath.item];
    UILabel *textLabel = (UILabel *) [cell viewWithTag:1];
    textLabel.text = [reward.text stringByReplacingEmojiCheatCodesWithUnicode];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UILabel *notesLabel = (UILabel *) [cell viewWithTag:2];
    notesLabel.text = [reward.notes stringByReplacingEmojiCheatCodesWithUnicode];
    notesLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UILabel *priceLabel = (UILabel *) [cell viewWithTag:3];
    priceLabel.text = [NSString stringWithFormat:@"%ld", (long) [reward.value integerValue]];
    UIImageView *goldView = (UIImageView *) [cell viewWithTag:4];
    [goldView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_gold.png"]
             placeholderImage:nil];
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:5];
    if ([reward.key isEqualToString:@"potion"]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_potion.png"]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    } else if ([reward.key isEqualToString:@"armoire"]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_armoire.png"]
                     placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    } else if (![reward.key isEqualToString:@"reward"]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/shop_%@.png", reward.key]]
                  placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    }
    
    if ([user.gold integerValue] < [reward.value integerValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        textLabel.textColor = [UIColor lightGrayColor];
        notesLabel.textColor = [UIColor lightGrayColor];
        imageView.alpha = 0.5;
        goldView.alpha = 0.5;
        priceLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        textLabel.textColor = [UIColor darkTextColor];
        notesLabel.textColor = [UIColor darkTextColor];
        imageView.alpha = 1;
        goldView.alpha = 1;
        priceLabel.textColor = [UIColor darkTextColor];
    }
}

- (void) handleLongCellPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        POPSpringAnimation *jumpAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        jumpAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        jumpAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        jumpAnimation.springBounciness = 20.f;
        [cell pop_addAnimation:jumpAnimation forKey:@"jumpAnimation"];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint p = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        self.editedReward = self.filteredData[indexPath.section][indexPath.item];
        [self performSegueWithIdentifier:@"FormSegue" sender:self];
    }
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
    [self addActivityCounter];
    if (formViewController.editReward) {
        [self.sharedManager updateReward:formViewController.reward onSuccess:^() {
            [self removeActivityCounter];
        } onError:^() {
            [self removeActivityCounter];
        }];
    } else {
        [self.sharedManager createReward:formViewController.reward onSuccess:^() {
            [self removeActivityCounter];
        } onError:^() {
            [self removeActivityCounter];
        }];
    }
}

@end
