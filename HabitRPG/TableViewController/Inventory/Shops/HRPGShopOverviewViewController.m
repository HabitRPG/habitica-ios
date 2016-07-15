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

@interface HRPGShopOverviewViewController ()

@end

@implementation HRPGShopOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *titleLabel = [cell viewWithTag:2];
    UILabel *descriptionLabel = [cell viewWithTag:3];
    
    switch (indexPath.item) {
        case 0: {
            [self.sharedManager setImage:@"npc_alex" withFormat:@"png" onView:imageView];
            titleLabel.text = NSLocalizedString(@"Market", nil);
            descriptionLabel.text = NSLocalizedString(@"Buy hard-to-find eggs, potions and food!", nil);
            break;
        }
        case 1: {
            [self.sharedManager setImage:@"npc_ian" withFormat:@"png" onView:imageView];
            titleLabel.text = NSLocalizedString(@"Quests", nil);
            descriptionLabel.text = NSLocalizedString(@"Purchase new quest scrolls!", nil);
            break;
        }
        case 2: {
            [self.sharedManager setImage:@"npc_timetravelers_active" withFormat:@"png" onView:imageView];
            titleLabel.text = NSLocalizedString(@"Time Travelers", nil);
            descriptionLabel.text = NSLocalizedString(@"", nil);
            break;
        }
        case 3: {
            [self.sharedManager setImage:@"seasonalshop_open" withFormat:@"png" onView:imageView];
            titleLabel.text = NSLocalizedString(@"Seasonal Shop", nil);
            descriptionLabel.text = NSLocalizedString(@"", nil);
            break;
        }
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShopSegue"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        switch (indexPath.item) {
            case 0:
                shopViewController.shopIdentifier = MarketKey;
                break;
            case 1:
                shopViewController.shopIdentifier = QuestsShopKey;
                break;
            case 2:
                shopViewController.shopIdentifier = TimeTravelersShopKey;
                break;
            case 3:
                shopViewController.shopIdentifier = SeasonalShopKey;
                break;
        }
    }
}

@end
