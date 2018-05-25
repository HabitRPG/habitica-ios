//
//  HRPGFeedViewController.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGBaseViewController.h"

@protocol FoodProtocol;

@interface HRPGFeedViewController : HRPGBaseViewController

@property(nonatomic) id<FoodProtocol> selectedFood;

@end
