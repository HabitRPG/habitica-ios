//
//  HRPGUIViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import "HRPGUIViewController.h"
#import "UIViewController+TutorialSteps.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"

@implementation HRPGUIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self hrpgTopHeaderNavigationController]) {
        [self hrpgTopHeaderNavigationController].hideNavbar = NO;
        [self hrpgTopHeaderNavigationController].navbarVisibleColor = [self hrpgTopHeaderNavigationController].defaultNavbarVisibleColor;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [super displayTutorialStep:[HRPGManager sharedManager]];
}

@end
