//
//  HRPGIntroView.h
//  Habitica
//
//  Created by Phillip Thelen on 11/11/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "EAIntroView.h"

@interface HRPGIntroView : NSObject

- (HRPGIntroView *)initWithFrame:(CGRect)frame;

- (void)displayInView:(UIView *)view;

- (void)setDelegate:(id<EAIntroDelegate>)delegate;

@end
