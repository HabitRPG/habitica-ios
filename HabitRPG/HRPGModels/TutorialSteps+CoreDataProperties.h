//
//  TutorialSteps+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TutorialSteps.h"

NS_ASSUME_NONNULL_BEGIN

@interface TutorialSteps (CoreDataProperties)

@property(nullable, nonatomic, retain) NSString *identifier;
@property(nullable, nonatomic, retain) NSString *type;
@property(nullable, nonatomic, retain) NSNumber *wasShown;
@property(nullable, nonatomic, retain) NSString *shownInView;
@property(nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
