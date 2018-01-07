//
//  HRPGUIViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import "HRPGUIViewController.h"
#import "UIViewController+TutorialSteps.h"

@implementation HRPGUIViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [super displayTutorialStep:[HRPGManager sharedManager]];
}

@end
