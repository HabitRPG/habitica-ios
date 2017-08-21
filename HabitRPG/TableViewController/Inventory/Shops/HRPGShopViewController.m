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

@property (nonatomic) HRPGShopBannerView *shopBannerView;

@property (nonatomic) HRPGShopCollectionViewDataSource *dataSource;
@property (nonatomic) HRPGShopViewModel *viewModel;

@property User *user;

@property NSIndexPath *selectedIndex;

@end

@implementation HRPGShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
    
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier];
    
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupNavBar];
    
    [self.topHeaderNavigationController setAlternativeHeaderView:self.shopBannerView];
    [self.topHeaderNavigationController startFollowingScrollView:self.collectionView];
    self.topHeaderNavigationController.shouldHideTopHeader = NO;
    
    User *user = [[HRPGManager sharedManager] getUser];
    if (user && user.health && user.health.floatValue <= 0) {
        [[HRPGDeathView new] show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.topHeaderNavigationController.shouldHideTopHeader = YES;
    [self.topHeaderNavigationController stopFollowingScrollView];
    [self.topHeaderNavigationController removeAlternativeHeaderView];
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchShopInventory:self.shopIdentifier onSuccess:^() {
        [self.viewModel fetchShopInformationForIdentifier:self.shopIdentifier];
        if (self.viewModel.shop) {
            self.navigationItem.title = self.viewModel.shop.text;
            self.shopBannerView.shop = self.viewModel.shop;
        }
        self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier];
        [self.collectionView reloadData];
    } onError:nil];
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
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.itemSize = CGSizeMake(80, 108);
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    self.collectionView.collectionViewLayout = collectionViewLayout;
    
    self.dataSource = [HRPGShopCollectionViewDataSource new];
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
}

- (void)configureEmptyLabel {
    self.collectionView.hidden = YES;
}

#pragma mark - data source delegate

- (void)didSelectItem:(ShopItem *)item {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BuyModal" bundle:nil];
    HRPGBuyItemModalViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HRPGBuyItemModalViewController"];
    vc.item = item;
    vc.shopIdentifier = self.shopIdentifier;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.topHeaderNavigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
}

#pragma mark - lazy loaders

- (HRPGShopViewModel *)viewModel {
    if (!_viewModel) _viewModel = [HRPGShopViewModel new];
    return _viewModel;
}

- (HRPGShopBannerView *)shopBannerView {
    if (!_shopBannerView) _shopBannerView = [[HRPGShopBannerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 165)];
    return _shopBannerView;
}

@end
