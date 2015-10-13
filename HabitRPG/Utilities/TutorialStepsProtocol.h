//
//  TutorialStepsProtocol.h
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

@protocol TutorialStepsProtocol <NSObject>

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property HRPGManager *sharedManager;

@optional
- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier;
- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier;

@end