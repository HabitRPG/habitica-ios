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
@property BOOL insetWasSetup;

@property NSString *selectedGearCategory;

@end

@implementation HRPGShopViewController

- (void)viewDidLoad {
    self.topHeaderNavigationController.shouldHideTopHeader = NO;
    [self.topHeaderNavigationController setAlternativeHeaderView:self.shopBannerView];

    [super viewDidLoad];
    
    self.topHeaderCoordinator.alternativeHeader = self.shopBannerView;

    [self setupNavBar];
    
    [self setupCollectionView];
    
    self.user = [[HRPGManager sharedManager] getUser];
    
    self.selectedGearCategory = self.user.hclass;
    
    self.dataSource.selectedGearCategory = self.selectedGearCategory;
    self.dataSource.fetchedResultsDelegate = self;
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier withGearCategory:self.selectedGearCategory];
    if ([self.shopIdentifier isEqualToString:@"market"]) {
        self.dataSource.needsGearSection = YES;
    }
    
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self scrollToTop];
    
    [self.user addObserver:self forKeyPath:@"gold" options:0 context:NULL];
    [self.user addObserver:self forKeyPath:@"balance" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.user removeObserver:self forKeyPath:@"gold"];
    [self.user removeObserver:self forKeyPath:@"balance"];
    
    [super viewWillDisappear:animated];
}


- (void)refresh {
    [self setupShop];
    [[HRPGManager sharedManager] fetchShopInventory:self.shopIdentifier onSuccess:^() {
        if ([self.shopIdentifier isEqualToString:MarketKey]) {
            [[HRPGManager sharedManager] fetchShopInventory:GearMarketKey onSuccess:nil onError:nil];
        }
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
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier withGearCategory:self.selectedGearCategory];
    [self.collectionView reloadData];
}

- (void)setupNavBar {
    HRPGCurrencyCountView *gems = [HRPGCurrencyCountView new];
    [gems setAsGems];
    gems.amount = [[NSNumber numberWithFloat:4.0f * [[[HRPGManager sharedManager] getUser].balance floatValue]] intValue];
    
    HRPGCurrencyCountView *gold = [HRPGCurrencyCountView new];
    [gold setAsGold];
    gold.amount = [[[HRPGManager sharedManager] getUser].gold intValue];
    
    UIBarButtonItem *gemsBarItem;
    UIBarButtonItem *goldBarItem;
    if (@available(iOS 11, *)) {
        gemsBarItem = [[UIBarButtonItem alloc] initWithCustomView:gems];
        goldBarItem = [[UIBarButtonItem alloc] initWithCustomView:gold];
    } else {
        gemsBarItem = [[UIBarButtonItem alloc] initWithCustomView:[self viewContainingCenteredView:gems]];
        goldBarItem = [[UIBarButtonItem alloc] initWithCustomView:[self viewContainingCenteredView:gold]];
    }
    
    self.navigationItem.rightBarButtonItems = @[goldBarItem, gemsBarItem];
}

- (UIView *)viewContainingCenteredView:(UIView *)view {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [container addSubview:view];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:0 metrics:nil views:@{@"view": view}]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]-(0)-|" options:0 metrics:nil views:@{@"view": view}]];
    return container;
}

- (void)setupCollectionView {
    [self.collectionView registerNib:[UINib nibWithNibName:@"InAppRewardCell" bundle:self.nibBundle] forCellWithReuseIdentifier:@"ItemCell"];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.itemSize = CGSizeMake(90, 120);
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 6, 20, 6);
    //self.collectionView.collectionViewLayout = collectionViewLayout;
    
    if ([self.shopIdentifier isEqualToString:@"timeTravelersShop"]) {
        self.dataSource = [TimeTravelersCollectionViewDataSource new];
    } else {
        self.dataSource = [HRPGShopCollectionViewDataSource new];
    }
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
    self.dataSource.ownedItems = [self.viewModel fetchOwnedItems];
    self.dataSource.pinnedItems = [self.viewModel fetchPinnedItems];
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
}

- (void)loadOwnedItems {
    self.dataSource.ownedItems = [self.viewModel fetchOwnedItems];
    [self.collectionView reloadData];
}

- (void)loadPinnedItems {
    self.dataSource.pinnedItems = [self.viewModel fetchPinnedItems];
    [self.collectionView reloadData];
}

- (void)scrollToTop {
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
    if (visualFormat != nil) {
        [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    }
    
    closedShopInfoView.image = [UIImage imageNamed:imageName];
    closedShopInfoView.shopItemTitleLabel.text = title;
    closedShopInfoView.shopItemDescriptionLabel.text = notes;
    
    [bgView setNeedsUpdateConstraints];
    [bgView updateConstraints];
    [bgView setNeedsLayout];
    [bgView layoutIfNeeded];
    
    self.collectionView.backgroundView = bgView;
}

#pragma mark - data source delegate

- (void)didSelectItem:(ShopItem *)item {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BuyModal" bundle:nil];
    HRPGBuyItemModalViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HRPGBuyItemModalViewController"];
    vc.item = item;
    vc.shopIdentifier = self.shopIdentifier;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.shopViewController = self;
    [self.tabBarController presentViewController:vc animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.viewModel shouldPromptToSubscribe]) {
        CGFloat alpha = scrollView.contentOffset.y + 350 + self.topHeaderNavigationController.contentInset - 80;
        alpha /= -80;
        if (alpha > 1) alpha = 1;
        if (alpha < 0) alpha = 0;
        self.collectionView.backgroundView.alpha = alpha;
    }
}

- (void)onEmptyFetchedResults {
    [self configureEmpty];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([@"gold" isEqualToString:keyPath] || [@"balance" isEqualToString:keyPath]) {
        [self setupNavBar];
    }
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

- (void)showGearSelection {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *title in @[@"warrior", @"mage", @"healer", @"rogue", @"none"]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[title capitalizedString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self changeSelectedGearCategory:title];
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeSelectedGearCategory:(NSString *)newGearCategory {
    self.selectedGearCategory = newGearCategory;
    self.dataSource.selectedGearCategory = newGearCategory;
    self.dataSource.fetchedResultsController = [self.viewModel fetchedShopItemResultsForIdentifier:self.shopIdentifier withGearCategory:self.selectedGearCategory];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

@end
