//
//  HRPGGoldView.h
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGGoldView : UIView

- (void)updateView:(NSNumber *)newGold withDiffString:(NSString *)amount;

@end
