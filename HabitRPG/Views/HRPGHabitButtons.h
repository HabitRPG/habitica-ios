//
//  HRPGHabitButton.h
//  Habitica
//
//  Created by viirus on 22.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGTaskProtocol.h"

@interface HRPGHabitButtons : UIView
@property (nonatomic) BOOL isLocked;

- (void)configureForTask:(NSObject<HRPGTaskProtocol> *)task isNegative:(BOOL)isNegative;

- (void)action:(void (^)())actionBlock;

@end
