//
//  ShopItem+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 14/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ShopItem.h"
#import "ShopCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShopItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSString *imageName;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSNumber *locked;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *value;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *purchaseType;
@property (nullable, nonatomic, retain) ShopCategory *category;

@end

NS_ASSUME_NONNULL_END
