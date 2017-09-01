//
//  QuestReward+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip on 28.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "QuestReward+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface QuestReward (CoreDataProperties)

+ (NSFetchRequest<QuestReward *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *key;
@property (nullable, nonatomic, copy) NSNumber *onlyOwner;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, retain) Quest *quest;

@end

NS_ASSUME_NONNULL_END
