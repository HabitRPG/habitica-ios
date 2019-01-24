//
//  HRPGUIViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 07.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialStepsProtocol.h"

@class TopHeaderCoordinator;

@interface HRPGUIViewController : UIViewController<TutorialStepsProtocol>

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property TutorialStepView *activeTutorialView;
@property TopHeaderCoordinator *topHeaderCoordinator;

- (void) populateText;
@end
