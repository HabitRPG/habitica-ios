//
//  HRPGFeedViewController.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFeedViewController.h"
#import "UIColor+Habitica.h"
#import "HRPGShopViewController.h"
#import "Habitica-Swift.h"

@interface HRPGFeedViewController ()

@property id<FeedViewDataSourceProtocol> dataSource;
@property NSString *shopIdentifier;

@end

@implementation HRPGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = objcL10n.titleFeedPet;
    
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
    UILabel *label = [view viewWithTag:2];
    UIButton *openShopButton = [view viewWithTag:3];
    
    openShopButton.layer.borderColor = [UIColor purple400].CGColor;
    openShopButton.layer.borderWidth = 1.0;
    openShopButton.layer.cornerRadius = 5;
    
    label.text = objcL10n.notGettingDrops;
    [openShopButton addTarget:self action:@selector(openMarket:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (void)openMarket:(UIButton *)button {
    self.shopIdentifier = @"market";
    [self performSegueWithIdentifier:@"ShowShopSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowShopSegue"]) {
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = self.shopIdentifier;
    }
}

@end
