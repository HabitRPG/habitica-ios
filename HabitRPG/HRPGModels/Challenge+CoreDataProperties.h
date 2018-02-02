//
//  Challenge+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 14/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Challenge+CoreDataClass.h"

@class ChallengeTask, ChallengeCategory;

NS_ASSUME_NONNULL_BEGIN

@interface Challenge (CoreDataProperties)

+ (NSFetchRequest<Challenge *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createdAt;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *leaderId;
@property (nullable, nonatomic, copy) NSString *leaderName;
@property (nullable, nonatomic, copy) NSNumber *memberCount;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *official;
@property (nullable, nonatomic, copy) NSNumber *prize;
@property (nullable, nonatomic, copy) NSString *shortName;
@property (nullable, nonatomic, copy) NSDate *updatedAt;
@property (nullable, nonatomic, retain) Group *group;
@property (nullable, nonatomic, retain) NSSet<ChallengeCategory *> *categories;
@property (nullable, nonatomic, retain) NSSet<ChallengeTask *> *habits;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) NSSet<ChallengeTask *> *dailies;
@property (nullable, nonatomic, retain) NSSet<ChallengeTask *> *todos;
@property (nullable, nonatomic, retain) NSSet<ChallengeTask *> *rewards;

@end

@interface Challenge (CoreDataGeneratedAccessors)

- (void)addHabitsObject:(ChallengeTask *)value;
- (void)removeHabitsObject:(ChallengeTask *)value;
- (void)addHabits:(NSSet<ChallengeTask *> *)values;
- (void)removeHabits:(NSSet<ChallengeTask *> *)values;

- (void)addDailiesObject:(ChallengeTask *)value;
- (void)removeDailiesObject:(ChallengeTask *)value;
- (void)addDailies:(NSSet<ChallengeTask *> *)values;
- (void)removeDailies:(NSSet<ChallengeTask *> *)values;

- (void)addTodosObject:(ChallengeTask *)value;
- (void)removeTodosObject:(ChallengeTask *)value;
- (void)addTodos:(NSSet<ChallengeTask *> *)values;
- (void)removeTodos:(NSSet<ChallengeTask *> *)values;

- (void)addRewardsObject:(ChallengeTask *)value;
- (void)removeRewardsObject:(ChallengeTask *)value;
- (void)addRewards:(NSSet<ChallengeTask *> *)values;
- (void)removeRewards:(NSSet<ChallengeTask *> *)values;

@end

NS_ASSUME_NONNULL_END
