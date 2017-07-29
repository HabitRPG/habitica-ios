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
#import "CAGradientLayer+HRPGShopGradient.h"
#import "Habitica-Swift.h"
#import "HRPGShopOverviewTableViewDataSource.h"

@interface HRPGShopOverviewViewController () <HRPGShopOverviewTableViewDataSourceDelegate>
@property (nonatomic) NSMutableDictionary *shopDictionary;
@property (nonatomic) HRPGShopOverviewTableViewDataSource *dataSource;

@end

@implementation HRPGShopOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShopDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.topHeaderNavigationController stopFollowingScrollView];
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
    
    self.dataSource.delegate = self;
    self.dataSource.shopDictionary = self.shopDictionary;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShopSegue"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = [self identifierAtIndex:indexPath.item];
    }
}

#pragma mark - Datasource delegate methods

- (NSString *)identifierAtIndex:(long)index {
    switch (index) {
        case 0: return MarketKey;
        case 1: return QuestsShopKey;
        case 2: return SeasonalShopKey;
        case 3: return TimeTravelersShopKey;
        default: return nil;
    }
}

- (void)needsShopRefreshForIdentifier:(NSString *)identifier at:(NSIndexPath *)indexPath {
    [self.sharedManager fetchShopInventory:identifier onSuccess:^{
        [self setupShopDictionary];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } onError:nil];
}

#pragma mark - lazy loaders

- (HRPGShopOverviewTableViewDataSource *)dataSource {
    if (!_dataSource) _dataSource = [HRPGShopOverviewTableViewDataSource new];
    return _dataSource;
}

@end
