//
//  HRPGRoundProgressView.h
//  Habitica
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGRoundProgressView : UIView

@property UIColor *backgroundStrokeColor;
@property UIColor *indicatorStrokeColor;
@property NSInteger strokeWidth;
@property NSInteger indicatorLength;
@property CGFloat roundTime;

- (void)beginAnimating;

@end
