//
//  SubscriptionPlan+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "SubscriptionPlan+CoreDataProperties.h"

@implementation SubscriptionPlan (CoreDataProperties)

+ (NSFetchRequest<SubscriptionPlan *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SubscriptionPlan"];
}

@dynamic consecutiveTrinkets;
@dynamic count;
@dynamic customerId;
@dynamic dateCreated;
@dynamic dateTerminated;
@dynamic gemCapExtra;
@dynamic gemsBought;
@dynamic owner;
@dynamic paymentMethod;
@dynamic planId;
@dynamic user;
@dynamic mysteryItemCount;

@end
