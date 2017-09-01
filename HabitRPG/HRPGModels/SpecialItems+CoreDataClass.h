//
//  SpecialItems+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface SpecialItems : NSManagedObject

- (NSArray *)ownedTransformationItemIDs;

@end

NS_ASSUME_NONNULL_END

#import "SpecialItems+CoreDataProperties.h"
