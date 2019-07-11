//
//  HRPGShopOverviewTableViewDataSource.m
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGShopOverviewTableViewDataSource.h"
#import "CAGradientLayer+HRPGShopGradient.h"
#import "Habitica-Swift.h"

@interface HRPGShopOverviewTableViewDataSource ()

@property NSString *shopSpriteSuffix;

@end

@implementation HRPGShopOverviewTableViewDataSource

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.shopSpriteSuffix = [[ConfigRepository new] stringWithVariable:ConfigVariableShopSpriteSuffix defaultValue:@""];
    }
    
    return self;
}

- (void)configureCell:(HRPGShopsTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSString *identifier = [self.delegate identifierAtIndex:indexPath.item];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.gradientImageView.gradient = [CAGradientLayer hrpgShopGradientLayer];
    cell.titleLabel.text = [self titleForIdentifier:identifier];
    
    id<ShopProtocol> shop = self.delegate.shopDictionary[identifier];
    if (shop) {
        [ImageManager getImageWithName:[NSString stringWithFormat:@"%@_background%@", identifier, self.shopSpriteSuffix] extension:@"png" completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
            cell.backgroundImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        }];
        [ImageManager setImageOn:cell.characterImageView name:[NSString stringWithFormat:@"%@_scene%@", identifier, self.shopSpriteSuffix] extension:@"png" completion:nil];
    }
    
    cell.backgroundImageView.contentMode = UIViewContentModeRedraw;
    
    cell.titleLabel.textColor = ObjcThemeWrapper.lightTextColor;
}

- (NSString *)titleForIdentifier:(NSString *)identifier {
    NSString *title = @"";
    
    NSObject<ShopProtocol> *shop = self.delegate.shopDictionary[identifier];
    if (shop) {
        title = [shop valueForKey:@"text"];
    }
    
    return title;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HRPGShopsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath tableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 124.0;
}

@end
