//
//  HRPGAcitivityIndicator.h
//  Habitica
//
//  Created by viirus on 15/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGActivityIndicator : UIView

- (void)beginAnimating;
- (void)endAnimating:(void (^)())completionBlock;
- (void)pauseAnimating;
- (void)animate;

- (void)setLineWidth:(CGFloat)width;
- (void)setInnerInset:(CGFloat)inset;
@end
