//
//  Preferences+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Preferences.h"

NS_ASSUME_NONNULL_BEGIN

@interface Preferences (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *background;
@property (nullable, nonatomic, retain) NSNumber *dayStart;
@property (nullable, nonatomic, retain) NSNumber *disableClass;
@property (nullable, nonatomic, retain) NSString *hairBangs;
@property (nullable, nonatomic, retain) NSString *hairBase;
@property (nullable, nonatomic, retain) NSString *hairBeard;
@property (nullable, nonatomic, retain) NSString *hairColor;
@property (nullable, nonatomic, retain) NSString *hairFlower;
@property (nullable, nonatomic, retain) NSString *hairMustache;
@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) NSString *shirt;
@property (nullable, nonatomic, retain) NSString *size;
@property (nullable, nonatomic, retain) NSString *skin;
@property (nullable, nonatomic, retain) NSNumber *sleep;
@property (nullable, nonatomic, retain) NSNumber *timezoneOffset;
@property (nullable, nonatomic, retain) NSNumber *useCostume;
@property (nullable, nonatomic, retain) NSString *userID;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
