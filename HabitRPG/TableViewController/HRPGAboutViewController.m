//
//  HRPGAboutViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 12/04/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAboutViewController.h"
#import "HRPGTopHeaderNavigationController.h"

@interface HRPGAboutViewController ()
@property BOOL shouldReshowTopHeader;
@property UIView *headerView;
@end

@implementation HRPGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-130)/2, 10, 130, 130)];
    headerImageView.image = [UIImage imageNamed:@"Logo"];
    [self.headerView addSubview:headerImageView];
    
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*)self.navigationController;
        if (navigationController.isTopHeaderVisible) {
            [navigationController hideTopBar];
            self.shouldReshowTopHeader = YES;
        } else {
            self.shouldReshowTopHeader = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*)self.navigationController;
        if (self.shouldReshowTopHeader) {
            [navigationController showTopBar];
        }
    }
    
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = @"BasicCell";
    if (indexPath.item == 0) {
        cellName = @"RightDetailCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    
    if (indexPath.item == 0) {
        cell.textLabel.text = NSLocalizedString(@"Website", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"habitrpg.com", nil);
    }
    
    return cell;
}



@end
