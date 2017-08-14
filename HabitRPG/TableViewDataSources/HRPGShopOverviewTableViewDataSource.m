//
//  HRPGShopOverviewTableViewDataSource.m
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "HRPGShopOverviewTableViewDataSource.h"
#import "CAGradientLayer+HRPGShopGradient.h"
#import "Habitica-Swift.h"
#import "Shop.h"

@implementation HRPGShopOverviewTableViewDataSource

- (void)configureCell:(HRPGShopsTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self.delegate identifierAtIndex:indexPath.item];
    
    cell.gradientImageView.gradient = [CAGradientLayer hrpgShopGradientLayer];
    cell.titleLabel.text = [self titleForIdentifier:identifier];
    cell.backgroundImageView.image = [self bgImageForIdentifier:identifier];
    cell.characterImageView.image = [self characterImageForIdentifier:identifier];
    
    Shop *shop = self.shopDictionary[identifier];
    if (shop) {
        if (shop.isNew) {
            cell.subtitleLabel.text = NSLocalizedString(@"New Stock!", nil);
        } else {
            cell.subtitleLabel.text = @"";
        }
    } else if ([self.delegate respondsToSelector:@selector(needsShopRefreshForIdentifier:at:)]) {
        [self.delegate needsShopRefreshForIdentifier:identifier at:indexPath];
    }
    
    cell.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (NSString *)titleForIdentifier:(NSString *)identifier {
    NSString *title = @"";
    
    Shop *shop = self.shopDictionary[identifier];
    if (shop) {
        title = shop.text;
    } else {
        title = NSLocalizedString([HRPGShopOverviewTableViewDataSource shopNames][identifier], nil);
    }
    
    return title;
}

- (UIImage *)bgImageForIdentifier:(NSString *)identifier {
    return [[UIImage imageNamed:[HRPGShopOverviewTableViewDataSource shopBgImageNames][identifier]] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
}

- (UIImage *)characterImageForIdentifier:(NSString *)identifier {
    return [UIImage imageNamed:[HRPGShopOverviewTableViewDataSource shopCharacterImageNames][identifier]];
}

#pragma mark - temporary asset sources

+ (NSDictionary *)shopBgImageNames {
    return @{
             MarketKey: @"market_summer_splash_banner_bg",
             QuestsShopKey: @"summer_coral_background",
             SeasonalShopKey: @"seasonal_shop_summer_splash_banner_bg",
             TimeTravelersShopKey: @"timetravelers_summer_splash_banner_bg"
             };
}

+ (NSDictionary *)shopCharacterImageNames {
    return @{
             MarketKey: @"market_summer_splash_banner_booth",
             QuestsShopKey: @"summer_ian_scene",
             SeasonalShopKey: @"seasonal_shop_summer_splash_banner_booth",
             TimeTravelersShopKey: @"timetravelers_summer_splash_banner_booth"
             };
}

+ (NSDictionary *)shopNames {
    return @{
             MarketKey: @"Market",
             QuestsShopKey: @"Quests",
             SeasonalShopKey: @"Seasonal Shop",
             TimeTravelersShopKey: @"Time Travelers",
             };
}

#pragma mark - UITableViewDataSource and Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shopDictionary.allKeys.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HRPGShopUserHeaderView *view = [[NSBundle mainBundle] loadNibNamed:@"HRPGShopUserHeaderView" owner:self options:nil][0];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HRPGShopsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 186.0;
}

@end
