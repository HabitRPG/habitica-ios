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
#import "MPCoachMarks.h"

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
            if (![nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                self.displayedTutorialStep = YES;
                NSDictionary *tutorialDefinition = [self getDefinitonForTutorial:self.tutorialIdentifier];
                HRPGExplanationView *explanationView = [[HRPGExplanationView alloc] init];
                explanationView.speechBubbleText = tutorialDefinition[@"text"];
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
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *defaultsKey = [NSString stringWithFormat:@"tutorial%@", coachMark];
                NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
                if ([nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                    return;
                }
                if ([self respondsToSelector:@selector(getFrameForCoachmark:)]) {
                    CGRect frame = [self getFrameForCoachmark:coachMark];
                    if (!CGRectEqualToRect(frame, CGRectZero)) {
                        self.displayedTutorialStep = YES;
                        NSDictionary *tutorialDefinition = [self getDefinitonForTutorial:coachMark];
                        NSArray *coachMarks = @[@{@"rect": [NSValue valueWithCGRect:frame], @"caption": tutorialDefinition[@"text"],}];
                        
                        UIViewController *topViewController = self.navigationController.parentViewController;
                        
                        MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:topViewController.view.bounds coachMarks:coachMarks];
                        coachMarksView.enableContinueLabel = NO;
                        coachMarksView.enableSkipButton = NO;
                        [topViewController.view addSubview:coachMarksView];
                        [coachMarksView start];
                        
                        TutorialSteps *step = [TutorialSteps markStep:coachMark asSeen:YES withContext:sharedManager.getManagedObjectContext];
                        [[sharedManager user] addTutorialStepsObject:step];
                        NSError *error;
                        [sharedManager.getManagedObjectContext saveToPersistentStore:&error];

                    }
                }
                break;
            }
        }
    }
}



@end

