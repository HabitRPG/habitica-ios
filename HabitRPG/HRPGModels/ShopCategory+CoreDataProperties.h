//
//  ShopCategory+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 15/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ShopCategory.h"

@class ShopItem;

NS_ASSUME_NONNULL_BEGIN

@interface ShopCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSNumber *purchaseAll;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSOrderedSet<ShopItem *> *items;
@property (nullable, nonatomic, retain) Shop *shop;

@end

@interface ShopCategory (CoreDataGeneratedAccessors)

- (void)insertObject:(ShopItem *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray<ShopItem *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(ShopItem *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray<ShopItem *> *)values;
- (void)addItemsObject:(ShopItem *)value;
- (void)removeItemsObject:(ShopItem *)value;
- (void)addItems:(NSOrderedSet<ShopItem *> *)values;
- (void)removeItems:(NSOrderedSet<ShopItem *> *)values;

@end

NS_ASSUME_NONNULL_END
