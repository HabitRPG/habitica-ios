//
//  HRPGShopViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGShopViewController.h"
#import "Shop.h"
#import "ShopItem+CoreDataClass.h"
#import "User.h"
#import "KLCPopup.h"
#import "NSString+StripHTML.h"
#import "Habitica-Swift.h"
#import "HRPGShopViewModel.h"

@interface HRPGShopViewController () <HRPGShopCollectionViewDataSourceDelegate, HRPGFetchedResultsCollectionViewDataSourceDelegate>

@property (nonatomic) HRPGShopBannerView *shopBannerView;

@property (nonatomic) HRPGShopCollectionViewDataSource *dataSource;
@property (nonatomic) HRPGShopViewModel *viewModel;

@property User *user;

@property NSIndexPath *selectedIndex;
@property (nonatomic) CGFloat extraHeight;

@end

@implementation HRPGShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupCollectionView];
    
    self.dataSource.fetchedResultsDelegate = self;
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier];
    
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupNavBar];
    
    [self.topHeaderNavigationController setAlternativeHeaderView:self.shopBannerView];
    [self.topHeaderNavigationController startFollowingScrollView:self.collectionView];
    self.topHeaderNavigationController.shouldHideTopHeader = NO;
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([self.topHeaderNavigationController getContentInset], 0, 0, 0);
    if (!self.extraHeight) {
        self.extraHeight = self.navigationController.navigationBar.bounds.size.height +
                            [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    [self scrollToTop];
    
    User *user = [[HRPGManager sharedManager] getUser];
    if (user && user.health && user.health.floatValue <= 0) {
        [[HRPGDeathView new] show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.topHeaderNavigationController.shouldHideTopHeader = YES;
    [self.topHeaderNavigationController stopFollowingScrollView];
    [self.topHeaderNavigationController removeAlternativeHeaderView];
    [super viewWillDisappear:animated];
}

- (void)refresh {
    [self setupShop];
    [[HRPGManager sharedManager] fetchShopInventory:self.shopIdentifier onSuccess:^() {
        [self setupShop];
    } onError:nil];
}

- (void)setupShop {
    [self.viewModel fetchShopInformationForIdentifier:self.shopIdentifier];
    if (self.viewModel.shop) {
        self.navigationItem.title = self.viewModel.shop.text;
        self.shopBannerView.shop = self.viewModel.shop;
        
        if ([self.viewModel shouldPromptToSubscribe]) [self configureEmpty];
    }
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier];
    [self.collectionView reloadData];
}

- (void)setupNavBar {
    HRPGCurrencyCountView *gems = [HRPGCurrencyCountView new];
    [gems setAsGems];
    gems.amount = [[NSNumber numberWithFloat:4.f * [[[HRPGManager sharedManager] getUser].balance floatValue]] intValue];
    
    HRPGCurrencyCountView *gold = [HRPGCurrencyCountView new];
    [gold setAsGold];
    gold.amount = [[[HRPGManager sharedManager] getUser].gold intValue];
    
    UIBarButtonItem *gemsBarItem = [[UIBarButtonItem alloc] initWithCustomView:gems];
    UIBarButtonItem *goldBarItem = [[UIBarButtonItem alloc] initWithCustomView:gold];
    self.navigationItem.rightBarButtonItems = @[goldBarItem, gemsBarItem];
}

- (void)setupCollectionView {
    [self.collectionView registerNib:[UINib nibWithNibName:@"InAppRewardCell" bundle:self.nibBundle] forCellWithReuseIdentifier:@"ItemCell"];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.itemSize = CGSizeMake(90, 120);
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 6, 20, 6);
    self.collectionView.collectionViewLayout = collectionViewLayout;
    
    self.dataSource = [HRPGShopCollectionViewDataSource new];
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
}

- (void)scrollToTop {
    [self.collectionView setContentInset:(UIEdgeInsetsMake([self.topHeaderNavigationController getContentInset] + self.extraHeight, 0, 60, 0))];
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)configureEmpty {
    HRPGSimpleShopItemView *closedShopInfoView = [[HRPGSimpleShopItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 400)];
    closedShopInfoView.shopItemTitleLabel.textColor = [UIColor gray200];
    closedShopInfoView.shopItemDescriptionLabel.textColor = [UIColor gray300];
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.collectionView.frame];
    bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [bgView addConstraint:[NSLayoutConstraint constraintWithItem:bgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[UIScreen mainScreen].bounds.size.width]];
    
    NSString *imageName;
    NSString *title;
    NSString *notes;
    NSDictionary *views;
    NSString *visualFormat;
    if ([self.shopIdentifier isEqualToString:SeasonalShopKey]) {
        imageName = @"shop_empty_seasonal";
        title = @"Come back soon!";
        notes = @"The Grand Galas happen close to the solstices and equinoxes, so check back then to find a fun assortment of special seasonal items!";
        
        visualFormat = @"V:|-280-[closedView]";
        views = @{@"closedView": closedShopInfoView};
    } else if ([self.shopIdentifier isEqualToString:TimeTravelersShopKey]) {
        imageName = @"shop_empty_hourglass";
        title = @"Subscribe for Hourglasses";
        notes = @"Earn one Mystic Hourglass for every three months of consecutive subscription, then use them to unlock limited edition items, pets, and mounts from the past... and future!";
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 38)];
        button.backgroundColor = [UIColor gray600];
        [button setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
        [button setTitle:@"I want to Subscribe" forState:UIControlStateNormal];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:38]];
        button.layer.cornerRadius = 6;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        [bgView addSubview:button];
        [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[button]-20-|" options:0 metrics:nil views:@{@"button": button}]];
        
        visualFormat = @"V:|-280-[closedView]-10-[button]";
        views = @{@"closedView": closedShopInfoView, @"button": button};
    }
    
    [bgView addSubview:closedShopInfoView];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[closedView]-0-|" options:0 metrics:nil views:@{@"closedView": closedShopInfoView}]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
    closedShopInfoView.image = [UIImage imageNamed:imageName];
    closedShopInfoView.shopItemTitleLabel.text = title;
    closedShopInfoView.shopItemDescriptionLabel.text = notes;
    
    [bgView setNeedsUpdateConstraints];
    [bgView updateConstraints];
    [bgView setNeedsLayout];
    [bgView layoutIfNeeded];
    
    self.collectionView.backgroundView = bgView;
    
    self.extraHeight = 350;
}

#pragma mark - data source delegate

- (void)didSelectItem:(ShopItem *)item {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BuyModal" bundle:nil];
    HRPGBuyItemModalViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HRPGBuyItemModalViewController"];
    vc.item = item;
    vc.shopIdentifier = self.shopIdentifier;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.tabBarController presentViewController:vc animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.topHeaderNavigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
    if ([self.viewModel shouldPromptToSubscribe]) {
        CGFloat alpha = scrollView.contentOffset.y + 350 + [self.topHeaderNavigationController getContentInset] - 80;
        alpha /= -80;
        if (alpha > 1) alpha = 1;
        if (alpha < 0) alpha = 0;
        self.collectionView.backgroundView.alpha = alpha;
    }
}

- (void)onEmptyFetchedResults {
    [self configureEmpty];
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
