//
//  TutorialSteps.h
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface TutorialSteps : NSManagedObject

+ (TutorialSteps *)markStep:(NSString *)identifier
                     asSeen:(BOOL)wasSeen
                   withType:(NSString *)type
                withContext:(NSManagedObjectContext *)context;
+ (TutorialSteps *)markStep:(NSString *)identifier
                   withType:(NSString *)type
                withContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "TutorialSteps+CoreDataProperties.h"
