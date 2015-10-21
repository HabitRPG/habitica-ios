//
//  UIViewController+TutorialSteps.h
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "TutorialStepsProtocol.h"

@interface UIViewController (TutorialSteps) <TutorialStepsProtocol>

- (void)displayTutorialStep:(HRPGManager *)sharedManager;



@end
