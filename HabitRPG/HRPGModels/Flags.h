//
//  Flags.h
//  Habitica
//
//  Created by Phillip Thelen on 26/04/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TutorialSteps, User;

NS_ASSUME_NONNULL_BEGIN

@interface Flags : NSManagedObject

- (void)addIosTutorialStepsObject:(TutorialSteps *)value;
- (void)addIosTutorialSteps:(NSSet *)values;
- (void)removeIosTutorialSteps:(NSSet *)values;

- (void)addCommonTutorialStepsObject:(TutorialSteps *)value;
- (void)addCommonTutorialSteps:(NSSet *)values;
- (void)removeCommonTutorialSteps:(NSSet *)values;

@end

NS_ASSUME_NONNULL_END

#import "Flags+CoreDataProperties.h"
