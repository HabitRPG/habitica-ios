//
//  SubscriptionPlan+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface SubscriptionPlan : NSManagedObject

- (Boolean) isActive;
@property (readonly) NSInteger totalGemCap;

@end

NS_ASSUME_NONNULL_END

#import "SubscriptionPlan+CoreDataProperties.h"
