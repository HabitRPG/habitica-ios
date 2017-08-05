//
//  HRPGShopViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGShopViewController.h"
#import "Shop.h"
#import "ShopItem+CoreDataClass.h"
#import "User.h"
#import "HRPGGearDetailView.h"
#import "KLCPopup.h"
#import "NSString+StripHTML.h"
#import "Habitica-Swift.h"
#import "HRPGShopViewModel.h"

@interface HRPGShopViewController () <HRPGShopCollectionViewDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *shopBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shopForegroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) HRPGShopCollectionViewDataSource *dataSource;
@property (nonatomic) HRPGShopViewModel *viewModel;

@property User *user;

@property NSIndexPath *selectedIndex;

@end

@implementation HRPGShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupCollectionView];
    
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier];
    
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupNavBar];
    
    User *user = [[HRPGManager sharedManager] getUser];
    if (user && user.health && user.health.floatValue <= 0) {
        [[HRPGDeathView new] show];
    }
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchShopInventory:self.shopIdentifier onSuccess:^() {
        [self.viewModel fetchShopInformationForIdentifier:self.shopIdentifier];
        if (self.viewModel.shop) {
            [self updateShopInformationViews];
        }
        self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier];
        [self.collectionView reloadData];
    }onError:nil];
}

- (void)setupNavBar {
    HRPGGemCountView *gems = [HRPGGemCountView new];
    gems.countLabel.text = [NSString stringWithFormat:@"%i", ([[NSNumber numberWithFloat:4.f * [[[HRPGManager sharedManager] getUser].balance floatValue]] intValue])];
    
    HRPGGoldCountView *gold = [HRPGGoldCountView new];
    gold.countLabel.text = [NSString stringWithFormat:@"%i", [[[HRPGManager sharedManager] getUser].gold intValue]];
    
    UIBarButtonItem *gemsBarItem = [[UIBarButtonItem alloc] initWithCustomView:gems];
    UIBarButtonItem *goldBarItem = [[UIBarButtonItem alloc] initWithCustomView:gold];
    self.navigationItem.rightBarButtonItems = @[goldBarItem, gemsBarItem];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    self.collectionView.collectionViewLayout = collectionViewLayout;
    
    self.dataSource = [HRPGShopCollectionViewDataSource new];
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
}

- (void) updateShopInformationViews {
    self.shopBackgroundImageView.image = [[UIImage imageNamed:[self shopBgImageNames][self.shopIdentifier]] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    self.shopForegroundImageView.image = [UIImage imageNamed:[self shopCharacterImageNames][self.shopIdentifier]];
    
    self.navigationItem.title = self.viewModel.shop.text;
    self.shopNameLabel.text = self.viewModel.shop.text;
    
    NSString *notes = [self.viewModel.shop.notes stringByStrippingHTML];
    self.notesLabel.text = notes;
}

- (NSDictionary *)shopBgImageNames {
    return @{
             MarketKey: @"market_summer_splash_banner_bg",
             QuestsShopKey: @"quest_shop_summer_splash_banner",
             SeasonalShopKey: @"seasonal_shop_summer_splash_banner_bg",
             TimeTravelersShopKey: @"timetravelers_summer_splash_banner_bg"
             };
}

- (NSDictionary *)shopCharacterImageNames {
    return @{
             MarketKey: @"market_summer_splash_banner_booth",
             QuestsShopKey: @"",
             SeasonalShopKey: @"seasonal_shop_summer_splash_banner_booth",
             TimeTravelersShopKey: @"timetravelers_summer_splash_banner_booth"
             };
}

- (void)configureEmptyLabel {
    self.collectionView.hidden = YES;
}

- (void)didSelectItem:(ShopItem *)item {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BuyModal" bundle:nil];
    HRPGBuyItemModalViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HRPGBuyItemModalViewController"];
    vc.item = item;
    vc.shopIdentifier = self.shopIdentifier;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - lazy loaders

- (HRPGShopViewModel *)viewModel {
    if (!_viewModel) _viewModel = [HRPGShopViewModel new];
    return _viewModel;
}

@end
