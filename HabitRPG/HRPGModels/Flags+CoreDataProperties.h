//
//  Flags+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 26/04/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Flags.h"

NS_ASSUME_NONNULL_BEGIN

@interface Flags (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *armoireEmpty;
@property (nullable, nonatomic, retain) NSNumber *armoireOpened;
@property (nullable, nonatomic, retain) NSNumber *armoireEnabled;
@property (nullable, nonatomic, retain) NSNumber *welcomed;
@property (nullable, nonatomic, retain) NSNumber *cronCount;
@property (nullable, nonatomic, retain) NSNumber *communityGuidelinesAccepted;
@property (nullable, nonatomic, retain) NSNumber *rebirthEnabled;
@property (nullable, nonatomic, retain) NSNumber *classSelected;
@property (nullable, nonatomic, retain) NSNumber *habitNewStuff;
@property (nullable, nonatomic, retain) NSNumber *itemsEnabled;
@property (nullable, nonatomic, retain) NSNumber *dropsEnabled;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) NSSet *iOSTutorialSteps;
@property (nullable, nonatomic, retain) NSSet *commonTutorialSteps;

@end

NS_ASSUME_NONNULL_END
