//
//  ChallengeTask+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 13/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "ChallengeTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChallengeTask (CoreDataProperties)

+ (NSFetchRequest<ChallengeTask *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSNumber *up;
@property (nullable, nonatomic, copy) NSNumber *down;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, retain) Challenge *challenge;

@end

NS_ASSUME_NONNULL_END
