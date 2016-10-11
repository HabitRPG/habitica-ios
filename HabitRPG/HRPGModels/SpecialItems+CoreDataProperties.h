//
//  SpecialItems+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "SpecialItems+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SpecialItems (CoreDataProperties)

+ (NSFetchRequest<SpecialItems *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *spookySparkles;
@property (nullable, nonatomic, copy) NSNumber *seafoam;
@property (nullable, nonatomic, copy) NSNumber *shinySeed;
@property (nullable, nonatomic, copy) NSNumber *snowball;
@property (nullable, nonatomic, copy) NSNumber *valentine;
@property (nullable, nonatomic, copy) NSNumber *nye;
@property (nullable, nonatomic, copy) NSNumber *greeting;
@property (nullable, nonatomic, copy) NSNumber *thankyou;
@property (nullable, nonatomic, copy) NSNumber *birthday;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
