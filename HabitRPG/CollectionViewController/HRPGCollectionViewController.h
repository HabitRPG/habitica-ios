//
//  HRPGCollectionViewController.h
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TopHeaderViewController, TopHeaderCoordinator;

@interface HRPGCollectionViewController : UICollectionViewController

@property (nonatomic, readonly) TopHeaderViewController *topHeaderNavigationController;
@property (nonatomic) TopHeaderCoordinator *topHeaderCoordinator;

@end
