//
//  TutorialSteps.m
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "TutorialSteps.h"
#import "User.h"

@implementation TutorialSteps

+ (TutorialSteps *)markStep:(NSString *)identifier asSeen:(BOOL)wasSeen withContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TutorialSteps" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", identifier]];
    NSError *errorFetch = nil;
    NSArray *array = [context executeFetchRequest:request error:&errorFetch];
    TutorialSteps *step;
    if (array.count > 1) {
        step = array[0];
    } else {
        step = [NSEntityDescription insertNewObjectForEntityForName:@"TutorialSteps"
                                                                inManagedObjectContext:context];
        step.identifier = identifier;
    }
    step.wasShown = [NSNumber numberWithBool:wasSeen];

    return step;
}

@end
