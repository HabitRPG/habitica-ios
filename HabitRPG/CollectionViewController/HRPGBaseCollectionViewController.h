//
//  HRPGBBaseCollectionViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 13/07/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialStepsProtocol.h"
#import "HRPGCollectionViewController.h"

@interface HRPGBaseCollectionViewController : HRPGCollectionViewController<TutorialStepsProtocol>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property CGFloat screenWidth;
@property BOOL hidesTopBar;

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property TutorialStepView *activeTutorialView;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

@end
