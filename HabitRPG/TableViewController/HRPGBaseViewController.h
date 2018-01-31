//
//  HRPGBaseViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "TutorialStepsProtocol.h"
@class TopHeaderViewController, TopHeaderCoordinator;

@interface HRPGBaseViewController : UITableViewController<TutorialStepsProtocol>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property CGFloat viewWidth;
@property NSString *readableScreenName;

@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property TutorialStepView *activeTutorialView;

@property (nonatomic, readonly) TopHeaderViewController *topHeaderNavigationController;
@property TopHeaderCoordinator *topHeaderCoordinator;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath;

@end
