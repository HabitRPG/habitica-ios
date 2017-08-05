//
//  HRPGFeedViewController.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGFeedViewController.h"
#import "HRPGCoreDataDataSource.h"
#import "UIColor+Habitica.h"
#import "HRPGShopViewController.h"
#import "Shop.h"

@interface HRPGFeedViewController ()

@property HRPGCoreDataDataSource *dataSource;
@property NSString *shopIdentifier;

@end

@implementation HRPGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

- (void) setupTableView {
    __weak HRPGFeedViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, Food *food, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withFood:food];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"owned > 0 && text != ''"];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
        NSArray *sortDescriptors = @[ indexDescriptor ];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"Food"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
    self.dataSource.emptyText = NSLocalizedString(@"You have no food", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.dataSource itemAtIndexPath:indexPath];
    NSInteger height =
        (NSInteger)([item.text boundingRectWithSize:CGSizeMake(260.0f, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                             NSFontAttributeName : [UIFont systemFontOfSize:18.0f]
                                         }
                                            context:nil]
                        .size.height +
                    22);
    if (height < 60) {
        return 60;
    }
    return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFood = [self.dataSource itemAtIndexPath:indexPath];
    return indexPath;
}


- (void)configureCell:(UITableViewCell *)cell withFood:(Food *)food {
    UILabel *textLabel = [cell viewWithTag:1];
    textLabel.text = food.text;
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UILabel *detailTextLabel = [cell viewWithTag:2];
    detailTextLabel.text = [NSString stringWithFormat:@"%@", food.owned];
    detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [detailTextLabel sizeToFit];
    [[HRPGManager sharedManager] setImage:[NSString stringWithFormat:@"Pet_Food_%@", food.key]
                      withFormat:@"png"
                          onView:cell.imageView];

    cell.imageView.contentMode = UIViewContentModeCenter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section+1 == [self.dataSource numberOfSections]) {
        return 180.0;
    } else {
        return [self.tableView sectionFooterHeight];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section+1 == [self.dataSource numberOfSections]) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"ShopAdFooter" owner:self options:nil] lastObject];
        UIImageView *imageView = [view viewWithTag:1];
        UILabel *label = [view viewWithTag:2];
        UIButton *openShopButton = [view viewWithTag:3];
        
        openShopButton.layer.borderColor = [UIColor purple400].CGColor;
        openShopButton.layer.borderWidth = 1.0;
        openShopButton.layer.cornerRadius = 5;
        
        [[HRPGManager sharedManager] setImage:@"npc_alex" withFormat:nil onView:imageView];
        label.text = NSLocalizedString(@"Not getting the right drops? Check out the Market to buy just the things you need!", nil);
        [openShopButton addTarget:self action:@selector(openMarket:) forControlEvents:UIControlEventTouchUpInside];
        return view;
    } else {
        return nil;
    }
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
