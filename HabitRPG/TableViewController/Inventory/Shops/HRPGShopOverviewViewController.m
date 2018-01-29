//
//  HRPGShopOverviewViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGShopOverviewViewController.h"
#import "HRPGShopViewController.h"
#import "Shop.h"
#import "NSString+StripHTML.h"
#import "UIColor+Habitica.h"
#import "CAGradientLayer+HRPGShopGradient.h"
#import "Habitica-Swift.h"
#import "HRPGShopOverviewTableViewDataSource.h"

@interface HRPGShopOverviewViewController () <HRPGShopsOverviewViewModelDelegate>
@property (nonatomic) NSMutableDictionary *shopDictionary;
@property (nonatomic) HRPGShopsOverviewViewModel *viewModel;
@property (nonatomic) HRPGShopOverviewTableViewDataSource *dataSource;

@end

@implementation HRPGShopOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topHeaderCoordinator.hideHeader = YES;
    
    self.viewModel.delegate = self;
    [self.viewModel fetchShops];
    [self.viewModel refreshShops];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.topHeaderNavigationController.shouldHideTopHeader = YES;
    [self.topHeaderNavigationController hideHeaderWithAnimated:NO];
    [self.topHeaderNavigationController stopFollowingScrollView];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.topHeaderNavigationController.shouldHideTopHeader = YES;
    [self.topHeaderNavigationController hideHeaderWithAnimated:NO];
    [self.topHeaderNavigationController stopFollowingScrollView];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)setupShopDictionary {
    self.dataSource.delegate = self.viewModel;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShopSegue"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = [self.viewModel identifierAtIndex:indexPath.item];
    }
}

#pragma mark - View model delegate methods

- (void)didFetchShops {
    [self setupShopDictionary];
    [self.tableView reloadData];
}

#pragma mark - lazy loaders

- (HRPGShopOverviewTableViewDataSource *)dataSource {
    if (!_dataSource) _dataSource = [HRPGShopOverviewTableViewDataSource new];
    return _dataSource;
}

- (HRPGShopsOverviewViewModel *)viewModel {
    if (!_viewModel) _viewModel = [HRPGShopsOverviewViewModel new];
    return _viewModel;
}

@end
