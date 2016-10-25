//
//  HRPGCoreDataDataSource.h
//  Habitica
//
//  Created by Phillip Thelen on 05/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGCoreDataDatasourceDelegate.h"

typedef void (^TableViewCellConfigureBlock)(id cell, id item, NSIndexPath *indexPath);
typedef void (^FetchRequestConfigureBlock)(NSFetchRequest *fetchRequestBlock);
typedef NSString*(^CellIdentifierBlock)(id item, NSIndexPath *indexPath);

@interface HRPGCoreDataDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property NSString *sectionNameKeyPath;
@property BOOL haveEmptyHeaderTitles;
@property NSString *emptyText;
@property CellIdentifierBlock cellIdentifierBlock;
@property (weak) id<HRPGCoreDataDataSourceDelegate> delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        entityName:(NSString *)entityName
                    cellIdentifier:(NSString *)cellIdentifier
                configureCellBlock:(TableViewCellConfigureBlock)configureCellBlock
                 fetchRequestBlock:(FetchRequestConfigureBlock)fetchRequestBlock
                     asDelegateFor:(UITableView *)tableView;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (id)cellAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;

- (void)reconfigureFetchRequest;

@end
