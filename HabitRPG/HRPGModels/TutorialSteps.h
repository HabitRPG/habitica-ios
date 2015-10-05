//
//  TutorialSteps.h
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface TutorialSteps : NSManagedObject

+ (TutorialSteps *) markStepAsSeen:(NSString *) identifier withContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "TutorialSteps+CoreDataProperties.h"
