//
//  HRPGCollectionViewController.m
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCollectionViewController.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"

@interface HRPGCollectionViewController ()
@end

@implementation HRPGCollectionViewController

- (void)viewDidLoad {
    self.topHeaderCoordinator = [[TopHeaderCoordinator alloc] initWithTopHeaderNavigationController:self.topHeaderNavigationController scrollView:self.collectionView];
    [super viewDidLoad];
    [self populateText];
    
    [ObjcHabiticaAnalytics logNavigationEventWithPageName:NSStringFromClass([self class])];
    
    [self.topHeaderCoordinator viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.topHeaderCoordinator viewWillAppear];
    
    if ([ObjcThemeWrapper.themeMode  isEqual: @"dark"]) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    } else if ([ObjcThemeWrapper.themeMode  isEqual: @"light"]) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.topHeaderCoordinator viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topHeaderCoordinator viewWillDisappear];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.topHeaderCoordinator scrollViewDidScroll];
}

- (TopHeaderViewController *)topHeaderNavigationController {
    return [self hrpgTopHeaderNavigationController];
}
    
- (void)populateText {
    
}

@end
