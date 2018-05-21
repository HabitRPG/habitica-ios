//
//  HRPGFeedViewController.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFeedViewController.h"
#import "HRPGCoreDataDataSource.h"
#import "UIColor+Habitica.h"
#import "HRPGShopViewController.h"
#import "Shop.h"
#import "Habitica-Swift.h"

@interface HRPGFeedViewController ()

@property id<FeedViewDataSourceProtocol> dataSource;
@property NSString *shopIdentifier;

@end

@implementation HRPGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

- (void) setupTableView {
    self.dataSource = [FeedViewDataSourceInstantiator instantiate];
    self.dataSource.tableView = self.tableView;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFood = [self.dataSource foodAt:indexPath];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 180.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"ShopAdFooter" owner:self options:nil] lastObject];
    UIImageView *imageView = [view viewWithTag:1];
    UILabel *label = [view viewWithTag:2];
    UIButton *openShopButton = [view viewWithTag:3];
    
    openShopButton.layer.borderColor = [UIColor purple400].CGColor;
    openShopButton.layer.borderWidth = 1.0;
    openShopButton.layer.cornerRadius = 5;
    
    label.text = NSLocalizedString(@"Not getting the right drops? Check out the Market to buy just the things you need!", nil);
    [openShopButton addTarget:self action:@selector(openMarket:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (void)openMarket:(UIButton *)button {
    self.shopIdentifier = MarketKey;
    [self performSegueWithIdentifier:@"ShowShopSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowShopSegue"]) {
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = self.shopIdentifier;
    }
}

@end
