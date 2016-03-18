//
//  HRPGArrayViewController.m
//  Habitica
//
//  Created by Phillip on 22/08/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGArrayViewController.h"

@interface HRPGArrayViewController ()

@end

@implementation HRPGArrayViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = self.items[indexPath.item];

    if (self.selectedIndex == indexPath.item) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.item;
    [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    return indexPath;
}

@end
