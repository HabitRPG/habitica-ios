//
//  HRPGTabBarController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"

@interface HRPGTabBarController : UITabBarController <EAIntroDelegate>

@property NSArray *selectedTags;

- (void) displayIntro;

@end
