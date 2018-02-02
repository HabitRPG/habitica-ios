//
//  ChallengeTask+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 13/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "ChallengeTask+CoreDataClass.h"
#import "HRPGTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChallengeTask (CoreDataProperties) <HRPGTaskProtocol>

+ (NSFetchRequest<ChallengeTask *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *attribute;
@property (nullable, nonatomic, retain) Challenge *challenge;
@property (nullable, nonatomic, copy) NSNumber *completed;
@property (nullable, nonatomic, copy) NSNumber *down;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSNumber *priority;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSNumber *up;
@property (nullable, nonatomic, copy) NSNumber *value;

@end

NS_ASSUME_NONNULL_END
