//
//  Outfit+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 17/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Outfit.h"

NS_ASSUME_NONNULL_BEGIN

@interface Outfit (CoreDataProperties)

@property(nullable, nonatomic, retain) NSString *armor;
@property(nullable, nonatomic, retain) NSString *back;
@property(nullable, nonatomic, retain) NSString *body;
@property(nullable, nonatomic, retain) NSString *eyewear;
@property(nullable, nonatomic, retain) NSString *head;
@property(nullable, nonatomic, retain) NSString *headAccessory;
@property(nullable, nonatomic, retain) NSString *shield;
@property(nullable, nonatomic, retain) NSString *weapon;
@property(nullable, nonatomic, retain) NSString *userID;
@property(nullable, nonatomic, retain) User *userCostume;
@property(nullable, nonatomic, retain) User *userEquipped;

@end

NS_ASSUME_NONNULL_END
