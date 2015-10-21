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
    HRPGAvatarSetupStepsAvatar,
    HRPGAvatarSetupStepsTasks
} HRPGavatarSetupSteps;

@interface HRPGAvatarSetupViewController : UIViewController <UIScrollViewDelegate>

@property NSInteger currentStep;
@property User *user;
@property NSManagedObjectContext *managedObjectContext;
@property BOOL shouldDismiss;

@end
