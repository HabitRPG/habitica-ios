//
//  HRPGBBaseCollectionViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 13/07/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "TutorialStepsProtocol.h"

@interface HRPGBaseCollectionViewController : UICollectionViewController<TutorialStepsProtocol>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) HRPGManager *sharedManager;
@property CGFloat screenWidth;
@property BOOL hidesTopBar;
@property NSString *readableScreenName;

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property HRPGExplanationView *activeTutorialView;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

@end
