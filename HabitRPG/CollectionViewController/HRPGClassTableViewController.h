//
//  HRPGClassCollectionViewController.h
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "TutorialStepsProtocol.h"

@interface HRPGClassTableViewController
    : UITableViewController<UIAlertViewDelegate, TutorialStepsProtocol>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property(nonatomic) HRPGManager *sharedManager;
@property NSIndexPath *selectedIndex;
@property NSString *tutorialIdentifier;
@property NSArray *coachMarks;
@property BOOL displayedTutorialStep;
@property HRPGExplanationView *activeTutorialView;

@property BOOL shouldResetClass;

@end
