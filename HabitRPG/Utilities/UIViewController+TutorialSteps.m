//
//  UIViewController+TutorialSteps.m
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "UIViewController+TutorialSteps.h"
#import "HRPGExplanationView.h"
#import "HRPGManager.h"
#import "TutorialSteps.h"

@implementation UIViewController (TutorialSteps)

@dynamic displayedTutorialStep;
@dynamic tutorialIdentifier;
@dynamic coachMarks;

- (void)displayTutorialStep:(HRPGManager *)sharedManager {
    if (self.tutorialIdentifier && !self.displayedTutorialStep) {
        if (![[sharedManager user] hasSeenTutorialStepWithIdentifier:self.tutorialIdentifier]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey = [NSString stringWithFormat:@"tutorial%@", self.tutorialIdentifier];
            NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
            if ([nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                return;
            }
            self.displayedTutorialStep = YES;
            NSError *error = nil;
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TutorialDefinitions"
                                                                 ofType:@"json"];
            NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                                 options:kNilOptions
                                                                   error:&error];
            if (error == nil) {
                HRPGExplanationView *explanationView = [[HRPGExplanationView alloc] init];
                explanationView.speechBubbleText = data[self.tutorialIdentifier][@"text"];
                [explanationView displayOnView:self.parentViewController.parentViewController.view animated:YES];
                
                explanationView.dismissAction= ^(BOOL wasSeen) {
                    TutorialSteps *step = [TutorialSteps markStep:self.tutorialIdentifier asSeen:wasSeen withContext:sharedManager.getManagedObjectContext];
                    [[sharedManager user] addTutorialStepsObject:step];
                    if (!wasSeen) {
                        //Show it again the next day
                        NSDate *nextAppearance = [[NSDate date] dateByAddingTimeInterval:86400];
                        [defaults setValue:nextAppearance forKey:defaultsKey];
                    }
                    NSError *error;
                    [sharedManager.getManagedObjectContext saveToPersistentStore:&error];
                };
            }
        }
    }
    
    if (self.coachMarks && !self.displayedTutorialStep) {
        for (NSString *coachMark in self.coachMarks) {
            if (![[sharedManager user] hasSeenTutorialStepWithIdentifier:coachMark]) {
                break;
            }
        }
    }
}

@end

