//
//  HRPGBaseViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialStepsProtocol.h"
@class TopHeaderCoordinator;
@protocol TopHeaderNavigationControllerProtocol;

@interface HRPGBaseViewController : UITableViewController<TutorialStepsProtocol>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property CGFloat viewWidth;
@property NSString *readableScreenName;

@property NSString *tutorialIdentifier;
@property BOOL displayedTutorialStep;
@property TutorialStepView *activeTutorialView;

@property BOOL isVisible;

@property TopHeaderCoordinator *topHeaderCoordinator;
@property (nonatomic, readonly) UINavigationController<TopHeaderNavigationControllerProtocol> *topHeaderNavigationController;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath;

- (void) populateText;

@end
