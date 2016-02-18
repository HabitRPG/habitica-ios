//
//  LifeCategory+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ImprovementCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImprovementCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
