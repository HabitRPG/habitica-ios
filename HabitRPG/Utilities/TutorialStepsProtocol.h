//
//  TutorialStepsProtocol.h
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//
#import "HRPGExplanationView.h"

@protocol TutorialStepsProtocol <NSObject>

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property (nonatomic) HRPGManager *sharedManager;
@property HRPGExplanationView *activeTutorialView;

@optional
- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier;
- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier;

@end