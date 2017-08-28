//
//  Quest+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip on 28.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "Quest+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Quest (CoreDataProperties)

+ (NSFetchRequest<Quest *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *bossDef;
@property (nullable, nonatomic, copy) NSNumber *bossHp;
@property (nullable, nonatomic, copy) NSString *bossName;
@property (nullable, nonatomic, copy) NSNumber *bossRage;
@property (nullable, nonatomic, copy) NSNumber *bossStr;
@property (nullable, nonatomic, copy) NSString *completition;
@property (nullable, nonatomic, copy) NSNumber *dropExp;
@property (nullable, nonatomic, copy) NSNumber *dropGp;
@property (nullable, nonatomic, copy) NSString *previous;
@property (nullable, nonatomic, copy) NSString *rageDescription;
@property (nullable, nonatomic, copy) NSString *rageTitle;
@property (nullable, nonatomic, retain) NSOrderedSet<QuestCollect *> *collect;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) NSSet<QuestReward *> *itemDrops;

@end

@interface Quest (CoreDataGeneratedAccessors)

- (void)insertObject:(QuestCollect *)value inCollectAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCollectAtIndex:(NSUInteger)idx;
- (void)insertCollect:(NSArray<QuestCollect *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCollectAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCollectAtIndex:(NSUInteger)idx withObject:(QuestCollect *)value;
- (void)replaceCollectAtIndexes:(NSIndexSet *)indexes withCollect:(NSArray<QuestCollect *> *)values;
- (void)addCollectObject:(QuestCollect *)value;
- (void)removeCollectObject:(QuestCollect *)value;
- (void)addCollect:(NSOrderedSet<QuestCollect *> *)values;
- (void)removeCollect:(NSOrderedSet<QuestCollect *> *)values;

- (void)addItemDropsObject:(QuestReward *)value;
- (void)removeItemDropsObject:(QuestReward *)value;
- (void)addItemDrops:(NSSet<QuestReward *> *)values;
- (void)removeItemDrops:(NSSet<QuestReward *> *)values;

@end

NS_ASSUME_NONNULL_END
