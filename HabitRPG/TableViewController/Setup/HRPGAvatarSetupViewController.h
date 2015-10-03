//
//  HRPGAvatarSetupViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 30/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

typedef enum HRPGAvatarSetupSteps : NSInteger {
    HRPGAvatarSetupStepsWelcome,
    HRPGAvatarSetupStepsSkin,
    HRPGAvatarSetupStepsShirt,
    HRPGAvatarSetupStepsHairStyle,
    HRPGAvatarSetupStepsHairColor,
    HRPGAvatarSetupStepsTasks
} HRPGavatarSetupSteps;

@interface HRPGAvatarSetupViewController : UIViewController

@property NSInteger currentStep;
@property NSInteger lastCompletedStep;
@property User *user;
@property NSManagedObjectContext *managedObjectContext;


@end
