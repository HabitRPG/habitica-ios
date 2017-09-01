//
//  SubscriptionPlan+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "SubscriptionPlan+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SubscriptionPlan (CoreDataProperties)

+ (NSFetchRequest<SubscriptionPlan *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *consecutiveTrinkets;
@property (nullable, nonatomic, copy) NSNumber *count;
@property (nullable, nonatomic, copy) NSString *customerId;
@property (nullable, nonatomic, copy) NSDate *dateCreated;
@property (nullable, nonatomic, copy) NSDate *dateTerminated;
@property (nullable, nonatomic, copy) NSNumber *gemCapExtra;
@property (nullable, nonatomic, copy) NSNumber *gemsBought;
@property (nullable, nonatomic, copy) NSString *owner;
@property (nullable, nonatomic, copy) NSString *paymentMethod;
@property (nullable, nonatomic, copy) NSString *planId;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, copy) NSNumber *mysteryItemCount;

@end

NS_ASSUME_NONNULL_END
