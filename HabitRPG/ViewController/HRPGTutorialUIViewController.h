//
//  HRPGTutorialUIViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 13.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialStepsProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HRPGTutorialUIViewController : UIViewController

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property TutorialStepView *activeTutorialView;
@end

NS_ASSUME_NONNULL_END
