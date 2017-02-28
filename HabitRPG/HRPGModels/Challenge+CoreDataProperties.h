//
//  Challenge+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 24/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "Challenge+CoreDataClass.h"


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
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
