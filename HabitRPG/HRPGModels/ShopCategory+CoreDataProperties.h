//
//  ShopCategory+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip on 22.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//

#import "ShopCategory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ShopCategory (CoreDataProperties)

+ (NSFetchRequest<ShopCategory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSNumber *index;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *purchaseAll;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *pinType;
@property (nullable, nonatomic, copy) NSString *path;
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
