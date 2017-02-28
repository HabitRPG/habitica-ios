//
//  Challenge+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 23/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, User;

NS_ASSUME_NONNULL_BEGIN

@interface Challenge : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Challenge+CoreDataProperties.h"
