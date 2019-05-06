//
//  HRPGShopViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGShopViewController.h"
#import "NSString+StripHTML.h"
#import "Habitica-Swift.h"

@interface HRPGShopViewController () 

@property (nonatomic) NPCBannerView *shopBannerView;

@property (nonatomic) id<ShopCollectionViewDataSourceProtocol> dataSource;

@property NSIndexPath *selectedIndex;
@property BOOL insetWasSetup;

@property NSString *selectedGearCategory;

@property HRPGCurrencyCountView *gemView;
@property HRPGCurrencyCountView *goldView;

@end

@implementation HRPGShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topHeaderCoordinator.alternativeHeader = self.shopBannerView;
    
    [self setupNavBar];
    
    [self setupCollectionView];
    
    self.dataSource.selectedGearCategory = self.selectedGearCategory;
    if ([self.shopIdentifier isEqualToString:@"market"]) {
        self.dataSource.needsGearSection = YES;
    }
    
    [self refresh];
    
    self.collectionView.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
}

- (void)populateText {
    
}

- (void)refresh {
    [self.dataSource retrieveShopInventory:nil];
}

- (void)setupNavBar {
    self.gemView = [HRPGCurrencyCountView new];
    [self.gemView setAsGems];
    
    self.goldView = [HRPGCurrencyCountView new];
    [self.goldView setAsGold];
    
    UIBarButtonItem *gemsBarItem;
    UIBarButtonItem *goldBarItem;
    if (@available(iOS 11, *)) {
        gemsBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.gemView];
        goldBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.goldView];
    } else {
        gemsBarItem = [[UIBarButtonItem alloc] initWithCustomView:[self viewContainingCenteredView:self.gemView]];
        goldBarItem = [[UIBarButtonItem alloc] initWithCustomView:[self viewContainingCenteredView:self.goldView]];
    }
    
    self.navigationItem.rightBarButtonItems = @[goldBarItem, gemsBarItem];
}

- (void)updateNavBarWithGold:(NSInteger)gold gems:(NSInteger)gems {
    self.gemView.amount = gems;
    self.goldView.amount = gold;
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
    self.collectionView.collectionViewLayout = collectionViewLayout;
    
    if ([self.shopIdentifier isEqualToString:@"timeTravelersShop"]) {
        self.dataSource = [ShopCollectionViewDataSourceInstantiator instantiateTimeTravelersWithDelegate:self];
    } else {
        self.dataSource = [ShopCollectionViewDataSourceInstantiator instantiateWithIdentifier:self.shopIdentifier delegate: self];
    }
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
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
    if ([self.shopIdentifier isEqualToString:@"seasonalShop"]) {
        imageName = @"shop_empty_seasonal";
        title = @"Come back soon!";
        notes = @"The Grand Galas happen close to the solstices and equinoxes, so check back then to find a fun assortment of special seasonal items!";
        
        visualFormat = @"V:|-280-[closedView]";
        views = @{@"closedView": closedShopInfoView};
    } else if ([self.shopIdentifier isEqualToString:@"timeTravelersShop"]) {
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

- (void)didSelectItem:(id<InAppRewardProtocol>)item {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BuyModal" bundle:nil];
    HRPGBuyItemModalViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HRPGBuyItemModalViewController"];
    vc.reward = item;
    vc.shopIdentifier = self.shopIdentifier;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.shopViewController = self;
    if (self.tabBarController != nil) {
        [self.tabBarController presentViewController:vc animated:YES completion:nil];
    } else if (self.navigationController) {
        [self.navigationController presentViewController:vc animated:YES completion:nil];
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

- (void)updateShopHeaderWithShop:(id<ShopProtocol>)shop {
    self.shopBannerView.shop = shop;
}

#pragma mark - lazy loaders

- (NPCBannerView *)shopBannerView {
    if (!_shopBannerView) _shopBannerView = [[NPCBannerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 165)];
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:objcL10n.cancel style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [alertController setSourceInCenter:self.view];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeSelectedGearCategory:(NSString *)newGearCategory {
    self.selectedGearCategory = newGearCategory;
    self.dataSource.selectedGearCategory = newGearCategory;
}

@end
