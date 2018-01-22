//
//  ChallengeCategory+CoreDataProperties.h
//  Habitica
//
//  Created by Elliot Schrock on 1/22/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import "ChallengeCategory+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChallengeCategory (CoreDataProperties)

@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *slug;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
