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
#import "HRPGManager.h"

@implementation HRPGShopOverviewTableViewDataSource

- (void)configureCell:(HRPGShopsTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSString *identifier = [self.delegate identifierAtIndex:indexPath.item];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.gradientImageView.gradient = [CAGradientLayer hrpgShopGradientLayer];
    cell.titleLabel.text = [self titleForIdentifier:identifier];
    
    Shop *shop = self.delegate.shopDictionary[identifier];
    if (shop) {
        if (shop.isNew) {
            cell.subtitleLabel.text = NSLocalizedString(@"New Stock!", nil);
        } else {
            cell.subtitleLabel.text = @"";
        }
        [[HRPGManager sharedManager] getImage:[NSString stringWithFormat:@"%@_background", identifier] withFormat:@"png" onSuccess:^(UIImage *image) {
            cell.backgroundImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        } onError:nil];
        [[HRPGManager sharedManager] setImage:[NSString stringWithFormat:@"%@_scene", identifier] withFormat:@"png" onView:cell.characterImageView];
    } else {
        [self.delegate refreshShopWithIdentifier:identifier onSuccess:^{
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } onError:nil];
    }
    
    cell.backgroundImageView.contentMode = UIViewContentModeRedraw;
}

- (NSString *)titleForIdentifier:(NSString *)identifier {
    NSString *title = @"";
    
    Shop *shop = self.delegate.shopDictionary[identifier];
    if (shop) {
        title = shop.text;
    } else {
        title = NSLocalizedString([HRPGShopOverviewTableViewDataSource shopNames][identifier], nil);
    }
    
    return title;
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
    return self.delegate.shopDictionary.allKeys.count;
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
    
    [self configureCell:cell forIndexPath:indexPath tableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 126.0;
}

@end
