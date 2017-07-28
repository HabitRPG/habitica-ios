//
//  HRPGShopOverviewViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGShopOverviewViewController.h"
#import "HRPGShopViewController.h"
#import "Shop.h"
#import "NSString+StripHTML.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGShopOverviewViewController ()

@property NSMutableDictionary *shopDictionary;

@end

@implementation HRPGShopOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShopDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [((HRPGTopHeaderNavigationController *)self.navigationController) stopFollowingScrollView];
}

- (void)setupShopDictionary {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shop"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *shops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (shops) {
        self.shopDictionary = [NSMutableDictionary dictionaryWithCapacity:shops.count];
        for (Shop *shop in shops) {
            [self.shopDictionary setObject:shop forKey:shop.identifier];
        }
    }
}

- (CAGradientLayer *)gradientLayer {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor purple50].CGColor];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    return gradient;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShopSegue"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = [self identifierAtIndex:indexPath.item];
    }
}

- (NSString *)identifierAtIndex:(long)index {
    switch (index) {
        case 0:
            return MarketKey;
            break;
        case 1:
            return QuestsShopKey;
            break;
        case 2:
            return SeasonalShopKey;
            break;
        case 3:
            return TimeTravelersShopKey;
            break;
        default:
            return nil;
    }
}

- (NSString *)titleForIndex:(NSIndexPath *)indexPath {
    NSString *title = @"";
    
    Shop *shop = self.shopDictionary[[self identifierAtIndex:indexPath.item]];
    if (shop) {
        title = shop.text;
    } else {
        switch (indexPath.item) {
            case 0: {
                title = NSLocalizedString(@"Market", nil);
                break;
            }
            case 1: {
                title = NSLocalizedString(@"Quests", nil);
                break;
            }
            case 2: {
                title = NSLocalizedString(@"Seasonal Shop", nil);
                break;
            }
            case 3: {
                title = NSLocalizedString(@"Time Travelers", nil);
                break;
            }
        }
        __weak HRPGShopOverviewViewController *weakSelf = self;
        [self.sharedManager fetchShopInventory:[self identifierAtIndex:indexPath.item] onSuccess:^{
            [weakSelf setupShopDictionary];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } onError:nil];
    }
    
    return title;
}

- (UIImage *)imageForIndex:(NSIndexPath *)indexPath {
    UIImage *image;
    switch (indexPath.item) {
        case 0: {
            image = [UIImage imageNamed:@"market_summer_splash_banner"];
            break;
        }
        case 1: {
            image = [UIImage imageNamed:@"quest_shop_summer_splash_banner"];
            break;
        }
        case 2: {
            image = [UIImage imageNamed:@"seasonal_shop_summer_splash_banner"];
            break;
        }
        case 3: {
            image = [UIImage imageNamed:@"timetravelers_summer_splash_banner"];
            break;
        }
    }
    
    return image;
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HRPGShopUserHeaderView *view = [[NSBundle mainBundle] loadNibNamed:@"HRPGShopUserHeaderView" owner:self options:nil][0];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *titleLabel = [cell viewWithTag:2];
    UILabel *descriptionLabel = [cell viewWithTag:3];
    GradientImageView *gradientImageView = [cell viewWithTag:4];
    
    gradientImageView.gradient = [self gradientLayer];
    
    titleLabel.text = [self titleForIndex:indexPath];
    
    Shop *shop = self.shopDictionary[[self identifierAtIndex:indexPath.item]];
    if (shop.isNew) {
        descriptionLabel.text = NSLocalizedString(@"New Stock!", nil);
    }
    
    gradientImageView.image = [self imageForIndex:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.width * 122.0/375.0;
}

@end
