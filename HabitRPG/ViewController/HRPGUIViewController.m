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

- (void)viewDidLoad {
    self.topHeaderCoordinator = [[TopHeaderCoordinator alloc] initWithTopHeaderNavigationController:[self hrpgTopHeaderNavigationController]];
    [super viewDidLoad];
    [self.topHeaderCoordinator viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.topHeaderCoordinator viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [super displayTutorialStep];
    
    [self.topHeaderCoordinator viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.topHeaderCoordinator viewWillDisappear];
    [super viewWillDisappear:animated];
}

@end
