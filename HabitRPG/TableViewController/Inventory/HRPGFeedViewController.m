//
//  HRPGFeedViewController.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGFeedViewController.h"
#import "HRPGCoreDataDataSource.h"
@interface HRPGFeedViewController ()

@property HRPGCoreDataDataSource *dataSource;

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
    [self.sharedManager setImage:[NSString stringWithFormat:@"Pet_Food_%@", food.key]
                      withFormat:@"png"
                          onView:cell.imageView];

    cell.imageView.contentMode = UIViewContentModeCenter;
}

@end
