//
//  Preferences.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "ImprovementCategory.h"

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Preferences : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (void)addImprovementCategoriesObject:(ImprovementCategory *)value;
- (void)addImprovementCategories:(NSSet *)values;
- (void)removeImprovementCategories:(NSSet *)values;

@end

NS_ASSUME_NONNULL_END

#import "Preferences+CoreDataProperties.h"
