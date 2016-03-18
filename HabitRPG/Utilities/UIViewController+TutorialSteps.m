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
#import "HRPGHintView.h"
#import "Amplitude.h"

@implementation UIViewController (TutorialSteps)

@dynamic displayedTutorialStep;
@dynamic tutorialIdentifier;
@dynamic coachMarks;
@dynamic sharedManager;
@dynamic activeTutorialView;

- (void)displayTutorialStep:(HRPGManager *)sharedManager {
    if (self.activeTutorialView) {
        if (self.activeTutorialView.hintView) {
            [self.activeTutorialView.hintView continueAnimating];
        }
        return;
    }
    if (self.tutorialIdentifier && !self.displayedTutorialStep) {
        if (![[sharedManager user] hasSeenTutorialStepWithIdentifier:self.tutorialIdentifier]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey =
                [NSString stringWithFormat:@"tutorial%@", self.tutorialIdentifier];
            NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
            if (!([nextAppearance compare:[NSDate date]] == NSOrderedDescending)) {
                self.displayedTutorialStep = YES;
                [self displayExlanationView:self.tutorialIdentifier
                           highlightingArea:CGRectZero
                               withDefaults:defaults
                              inDefaultsKey:defaultsKey
                           withTutorialType:@"common"];
            }
        }
    }

    if (self.coachMarks && !self.displayedTutorialStep) {
        for (NSString *coachMark in self.coachMarks) {
            if (![[sharedManager user] hasSeenTutorialStepWithIdentifier:coachMark]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *defaultsKey = [NSString stringWithFormat:@"tutorial%@", coachMark];
                NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
                if ([nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                    continue;
                }
                if ([self respondsToSelector:@selector(getFrameForCoachmark:)]) {
                    CGRect frame = [self getFrameForCoachmark:coachMark];
                    if (!CGRectEqualToRect(frame, CGRectZero)) {
                        self.displayedTutorialStep = YES;
                        [self displayExlanationView:coachMark
                                   highlightingArea:frame
                                       withDefaults:defaults
                                      inDefaultsKey:defaultsKey
                                   withTutorialType:@"ios"];
                    }
                }
                break;
            }
        }
    }
}

- (void)displayExlanationView:(NSString *)identifier
             highlightingArea:(CGRect)frame
                 withDefaults:(NSUserDefaults *)defaults
                inDefaultsKey:(NSString *)defaultsKey
             withTutorialType:(NSString *)type {
    TutorialSteps *step = [TutorialSteps markStep:identifier
                                         withType:type
                                      withContext:self.sharedManager.getManagedObjectContext];
    NSString *className = NSStringFromClass([self class]);
    if ([step.wasShown boolValue]) {
        return;
    }
    if (step.shownInView && ![step.shownInView isEqualToString:className]) {
        return;
    }

    step.shownInView = className;
    step.wasShown = @YES;
    NSError *error;
    [self.sharedManager.getManagedObjectContext saveToPersistentStore:&error];

    NSDictionary *tutorialDefinition = [self getDefinitonForTutorial:identifier];
    HRPGExplanationView *explanationView = [[HRPGExplanationView alloc] init];
    self.activeTutorialView = explanationView;
    explanationView.speechBubbleText = tutorialDefinition[@"text"];
    if (!CGRectIsEmpty(frame)) {
        explanationView.highlightedFrame = frame;
        [explanationView displayHintOnView:self.parentViewController.view
                           withDisplayView:self.parentViewController.parentViewController.view
                                  animated:YES];
    } else {
        [explanationView displayOnView:self.parentViewController.parentViewController.view
                              animated:YES];
    }
    if ([type isEqualToString:@"common"]) {
        [[self.sharedManager user] addCommonTutorialStepsObject:step];
    } else {
        [[self.sharedManager user] addIosTutorialStepsObject:step];
    }

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"tutorial" forKey:@"eventAction"];
    [eventProperties setValue:@"behaviour" forKey:@"eventCategory"];
    [eventProperties setValue:@"event" forKey:@"event"];
    [eventProperties setValue:[step.identifier stringByAppendingString:@"-iOS"]
                       forKey:@"eventLabel"];
    [eventProperties setValue:step.identifier forKey:@"eventValue"];
    [eventProperties setValue:@NO forKey:@"complete"];
    [[Amplitude instance] logEvent:@"tutorial" withEventProperties:eventProperties];

    explanationView.dismissAction = ^(BOOL wasSeen) {
        self.activeTutorialView = nil;

        if (!wasSeen) {
            // Show it again the next day
            NSDate *nextAppearance = [[NSDate date] dateByAddingTimeInterval:86400];
            [defaults setValue:nextAppearance forKey:defaultsKey];
        } else {
            NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
            [eventProperties setValue:@"tutorial" forKey:@"eventAction"];
            [eventProperties setValue:@"behaviour" forKey:@"eventCategory"];
            [eventProperties setValue:@"event" forKey:@"event"];
            [eventProperties setValue:[step.identifier stringByAppendingString:@"-iOS"]
                               forKey:@"eventLabel"];
            [eventProperties setValue:step.identifier forKey:@"eventValue"];
            [eventProperties setValue:@YES forKey:@"complete"];
            [[Amplitude instance] logEvent:@"tutorial" withEventProperties:eventProperties];
        }
        NSError *error;
        [self.sharedManager.getManagedObjectContext saveToPersistentStore:&error];
        [self.sharedManager updateUser:@{
            [NSString stringWithFormat:@"flags.tutorial.%@.%@", type, step.identifier] :
                [NSNumber numberWithBool:wasSeen]
        }
                             onSuccess:nil
                               onError:nil];
    };
}

- (void)removeActiveView {
    if (self.activeTutorialView) {
        [self.activeTutorialView removeFromSuperview];
        self.activeTutorialView = nil;
    }
}

@end
