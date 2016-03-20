//
//  HRPGHintView.h
//  Habitica
//
//  Created by Phillip Thelen on 21/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGHintView : UIView

- (void)pulseToSize:(float)value withDuration:(float)duration;
- (void)continueAnimating;
@end
