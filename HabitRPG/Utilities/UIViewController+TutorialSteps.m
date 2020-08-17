//
//  UIViewController+TutorialSteps.m
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "UIViewController+TutorialSteps.h"
#import "Amplitude.h"
#import "Habitica-Swift.h"

@implementation UIViewController (TutorialSteps)

@dynamic displayedTutorialStep;
@dynamic tutorialIdentifier;
@dynamic activeTutorialView;

- (void)displayTutorialStep {
    if (self.activeTutorialView) {
        if (self.activeTutorialView.hintView) {
            [self.activeTutorialView.hintView continueAnimating];
        }
        return;
    }
    if (self.tutorialIdentifier && !self.displayedTutorialStep) {
        if ([UserManager.shared shouldDisplayTutorialStepWithKey:self.tutorialIdentifier]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey =
                [NSString stringWithFormat:@"tutorial%@", self.tutorialIdentifier];
            NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
            if (!([nextAppearance compare:[NSDate date]] == NSOrderedDescending)) {
                self.displayedTutorialStep = YES;
                [self displayExlanationView:self.tutorialIdentifier
                               withDefaults:defaults
                              inDefaultsKey:defaultsKey
                           withTutorialType:@"common"];
            }
        }
    }
}

- (void)displayExlanationView:(NSString *)identifier
                 withDefaults:(NSUserDefaults *)defaults
                inDefaultsKey:(NSString *)defaultsKey
             withTutorialType:(NSString *)type {

    NSDictionary *tutorialDefinition = [self getDefinitonForTutorial:identifier];
    TutorialStepView *tutorialStepView = [[TutorialStepView alloc] init];
    self.activeTutorialView = tutorialStepView;
    if (tutorialDefinition[@"textList"]) {
        [tutorialStepView setTextsWithList:tutorialDefinition[@"textList"]];
    } else {
        [tutorialStepView setText:tutorialDefinition[@"text"]];
    }
    [tutorialStepView displayOnView:self.parentViewController.parentViewController.view animated:YES];

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"tutorial" forKey:@"eventAction"];
    [eventProperties setValue:@"behaviour" forKey:@"eventCategory"];
    [eventProperties setValue:@"event" forKey:@"event"];
    [eventProperties setValue:[identifier stringByAppendingString:@"-iOS"]
                       forKey:@"eventLabel"];
    [eventProperties setValue:identifier forKey:@"eventValue"];
    [eventProperties setValue:@NO forKey:@"complete"];
    [[Amplitude instance] logEvent:@"tutorial" withEventProperties:eventProperties];

    tutorialStepView.dismissAction = ^() {
        self.activeTutorialView = nil;
        
        NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
        [eventProperties setValue:@"tutorial" forKey:@"eventAction"];
        [eventProperties setValue:@"behaviour" forKey:@"eventCategory"];
        [eventProperties setValue:@"event" forKey:@"event"];
        [eventProperties setValue:[identifier stringByAppendingString:@"-iOS"]
                           forKey:@"eventLabel"];
        [eventProperties setValue:identifier forKey:@"eventValue"];
        [eventProperties setValue:@YES forKey:@"complete"];
        [[Amplitude instance] logEvent:@"tutorial" withEventProperties:eventProperties];
        [UserManager.shared markTutorialAsSeenWithType:type key:identifier];
    };
}

- (void)removeActiveView {
    if (self.activeTutorialView) {
        [self.activeTutorialView removeFromSuperview];
        self.activeTutorialView = nil;
    }
}

@end
