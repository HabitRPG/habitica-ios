//
//  Buff+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Buff+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Buff (CoreDataProperties)

+ (NSFetchRequest<Buff *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *constitution;
@property (nullable, nonatomic, copy) NSNumber *intelligence;
@property (nullable, nonatomic, copy) NSNumber *perception;
@property (nullable, nonatomic, copy) NSNumber *seafoam;
@property (nullable, nonatomic, copy) NSNumber *shinySeed;
@property (nullable, nonatomic, copy) NSNumber *snowball;
@property (nullable, nonatomic, copy) NSNumber *spookySparkles;
@property (nullable, nonatomic, copy) NSNumber *strength;
@property (nullable, nonatomic, copy) NSNumber *streak;
@property (nullable, nonatomic, copy) NSString *userID;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
