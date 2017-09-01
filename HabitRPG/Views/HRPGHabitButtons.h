//
//  HRPGHabitButton.h
//  Habitica
//
//  Created by viirus on 22.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task+CoreDataClass.h"

@interface HRPGHabitButtons : UIView

- (void)configureForTask:(Task *)task isNegative:(BOOL)isNegative;

- (void)action:(void (^)())actionBlock;

@end
