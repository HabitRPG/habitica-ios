//
//  InAppReward+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "InAppReward+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface InAppReward (CoreDataProperties)

+ (NSFetchRequest<InAppReward *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *key;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *purchaseType;
@property (nullable, nonatomic, copy) NSString *pinType;
@property (nullable, nonatomic, copy) NSString *path;
@property (nullable, nonatomic, copy) NSNumber *isSuggested;
@property (nullable, nonatomic, copy) NSNumber *locked;
@property (nullable, nonatomic, copy) NSNumber *value;
@property (nullable, nonatomic, copy) NSString *currency;
@property (nullable, nonatomic, copy) NSString *imageName;

@end

NS_ASSUME_NONNULL_END
