//
//  Preferences.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
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
