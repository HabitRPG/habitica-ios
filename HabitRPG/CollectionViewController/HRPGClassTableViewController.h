//
//  HRPGClassCollectionViewController.h
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "TutorialStepsProtocol.h"

@interface HRPGClassTableViewController : UITableViewController<TutorialStepsProtocol>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property NSIndexPath *selectedIndex;
@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property TutorialStepView *activeTutorialView;

@property BOOL shouldResetClass;

@end
