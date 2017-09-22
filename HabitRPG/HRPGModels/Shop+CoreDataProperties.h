//
//  Shop+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 14/07/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Shop.h"
#import "ShopCategory+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Shop (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *imageName;
@property (nullable, nonatomic, retain) NSOrderedSet *categories;

@end

@interface Shop (CoreDataGeneratedAccessors)

- (void)insertObject:(ShopCategory *)value inCategoriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCategoriesAtIndex:(NSUInteger)idx;
- (void)insertCategories:(NSArray<ShopCategory *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCategoriesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCategoriesAtIndex:(NSUInteger)idx withObject:(ShopCategory *)value;
- (void)replaceCategoriesAtIndexes:(NSIndexSet *)indexes withCategories:(NSArray<ShopCategory *> *)values;
- (void)addCategoriesObject:(ShopCategory *)value;
- (void)removeCategoriesObject:(ShopCategory *)value;
- (void)addCategories:(NSOrderedSet<ShopCategory *> *)values;
- (void)removeCategories:(NSOrderedSet<ShopCategory *> *)values;

@end

NS_ASSUME_NONNULL_END
