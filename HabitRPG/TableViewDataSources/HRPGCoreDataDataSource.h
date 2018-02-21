//
//  HRPGCoreDataDataSource.h
//  Habitica
//
//  Created by Phillip Thelen on 05/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCoreDataDatasourceDelegate.h"

typedef void (^TableViewCellConfigureBlock)(id _Nullable cell, id item, NSIndexPath *indexPath);
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

- (_Nullable id)itemAtIndexPath:(NSIndexPath *_Nonnull)indexPath;
- (_Nullable id)cellAtIndexPath:(NSIndexPath *_Nonnull)indexPath;
- (NSArray *_Nullable)items;
- (NSInteger)numberOfSections;

- (void)reconfigureFetchRequest;

@end
