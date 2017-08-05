//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGRewardsViewController.h"
#import "HRPGGearDetailView.h"
#import "HRPGNavigationController.h"
#import "HRPGRewardFormViewController.h"
#import "HRPGRewardTableViewCell.h"
#import "KLCPopup.h"
#import "Reward.h"
#import "HRPGCoreDataDataSource.h"

@interface HRPGRewardsViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;
@property Reward *editedReward;
@property User *user;
@property HRPGCoreDataDataSource *dataSource;
@end

@implementation HRPGRewardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"HRPGRewardTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    [self setupTableView];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.user = [HRPGManager sharedManager].user;
    self.tutorialIdentifier = @"rewards";

    [[HRPGManager sharedManager] fetchBuyableRewards:nil onError:nil];
}

- (void)setupTableView {
    __weak HRPGRewardsViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(HRPGRewardTableViewCell *cell, MetaReward *reward, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withReward:reward];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        NSString *predicateString = @"type == 'reward' || type == 'potion' ||buyable == true";
        if ([weakSelf.user.flags.armoireEnabled boolValue]) {
            predicateString = [predicateString stringByAppendingString:@" || type == 'armoire'"];
        }
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateString]];
        
        NSSortDescriptor *keyDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
        NSSortDescriptor *orderDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:NO];
        NSSortDescriptor *rewardTypeDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"rewardType" ascending:NO];
        NSArray *sortDescriptors =
        @[ rewardTypeDescriptor, typeDescriptor, orderDescriptor, keyDescriptor ];
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"MetaReward"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
    self.dataSource.delegate = self;
}
- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"rewards"]) {
        return @{
            @"textList" : @[NSLocalizedString(@"Buy gear for your avatar with the gold you earn!", nil),
                            NSLocalizedString(@"You can also make real-world Custom Rewards based on what motivates you.", nil)]
        };
    }
    return nil;
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchUser:^() {
        [[HRPGManager sharedManager] fetchBuyableRewards:^{
            [self.refreshControl endRefreshing];
        } onError:^{
            [self.refreshControl endRefreshing];
            [[HRPGManager sharedManager] displayNetworkError];
        }];
    } onError:^() {
        [self.refreshControl endRefreshing];
        [[HRPGManager sharedManager] displayNetworkError];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 40.0f;
    float width = self.viewWidth - 127;
    MetaReward *reward = [self.dataSource itemAtIndexPath:indexPath];
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
        height = height +
                 [[self getArmoireFillStatus]
                     boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{
                                   NSFontAttributeName :
                                       [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                               }
                                  context:nil]
                     .size.height;
    }
    if (height < 87) {
        return 87;
    }
    return height;
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self.dataSource itemAtIndexPath:indexPath];
    return [reward.type isEqualToString:@"reward"];
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self.dataSource itemAtIndexPath:indexPath];
    if ([reward isKindOfClass:[Reward class]]) {
        [[HRPGManager sharedManager] deleteReward:(Reward *)reward
                               onSuccess:nil onError:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MetaReward *reward = [self.dataSource itemAtIndexPath:indexPath];
    if ([reward isKindOfClass:[Reward class]]) {
        self.editedReward = (Reward *)reward;
        [self performSegueWithIdentifier:@"FormSegue" sender:self];
    } else {
        NSArray *nibViews =
            [[NSBundle mainBundle] loadNibNamed:@"HRPGGearDetailView" owner:self options:nil];
        HRPGGearDetailView *gearView = nibViews[0];
        [gearView configureForReward:reward withGold:[self.user.gold floatValue]];
        gearView.buyAction = ^() {
            if ([reward isKindOfClass:[Reward class]]) {
                [[HRPGManager sharedManager] getReward:reward.key onSuccess:nil onError:nil];
            } else {
                [[HRPGManager sharedManager] buyObject:reward onSuccess:nil onError:nil];
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
        [[HRPGManager sharedManager] setImage:imageName withFormat:@"png" onView:gearView.imageView];
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


- (void)configureCell:(HRPGRewardTableViewCell *)cell withReward:(MetaReward *)reward {
    if (!reward) {
        return;
    }

    [cell configureForReward:reward withGoldOwned:self.user.gold];

    if (![reward isKindOfClass:[Reward class]]) {
        NSString *imageName = nil;
        if ([reward.key isEqualToString:@"potion"]) {
            imageName = @"shop_potion";
        } else if ([reward.key isEqualToString:@"armoire"]) {
            imageName = @"shop_armoire";
            cell.detailLabel.text = [self getArmoireFillStatus];
        } else if (![reward.key isEqualToString:@"reward"]) {
            imageName = [NSString stringWithFormat:@"shop_%@", reward.key];
        }
        if (imageName) {
            [[HRPGManager sharedManager] setImage:imageName withFormat:@"png" onView:cell.shopImageView];
        } else {
            cell.shopImageView.image = nil;
        }
    } else {
        cell.shopImageView.image = [UIImage imageNamed:@"tabbar_rewards"];
    }

    __weak HRPGRewardsViewController *weakSelf = self;
    [cell onPurchaseTap:^() {
        if ([reward isKindOfClass:[Reward class]]) {
            [[HRPGManager sharedManager]
                getReward:reward.key
                onSuccess:^() {
                    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
                        [weakSelf configureCell:[self.tableView cellForRowAtIndexPath:indexPath] withReward:[self.dataSource itemAtIndexPath:indexPath]];
                    }
                }
                  onError:nil];
        } else {
            reward.buyable = @NO;
            [[HRPGManager sharedManager] buyObject:reward
                onSuccess:^() {
                    [[HRPGManager sharedManager] fetchBuyableRewards:^() {
                        for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
                            [weakSelf configureCell:[self.tableView cellForRowAtIndexPath:indexPath] withReward:[self.dataSource itemAtIndexPath:indexPath]];
                        }
                    } onError:nil];
                }
                onError:^() {
                    reward.buyable = @YES;
                    NSError *error;
                    [weakSelf.managedObjectContext save:&error];
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
    HRPGRewardFormViewController *formViewController = segue.sourceViewController;
    if (formViewController.editReward) {
        [[HRPGManager sharedManager] updateReward:formViewController.reward onSuccess:nil onError:nil];
    } else {
        [[HRPGManager sharedManager] createReward:formViewController.reward onSuccess:nil onError:nil];
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
