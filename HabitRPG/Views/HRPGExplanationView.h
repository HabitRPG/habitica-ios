//
//  HRPGExplanationView.h
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HRPGExplanationViewPositionTop,
    HRPGExplanationViewPositionCenter,
    HRPGExplanationViewPositionBottom,
} HRPGExplanationViewPosition;

@interface HRPGExplanationView : UIView

@property (nonatomic) NSString *speechBubbleText;
@property (nonatomic) HRPGExplanationViewPosition position;
@property (nonatomic) UIColor *speechBubbleTextColor;
@property (nonatomic) CGRect highlightedFrame;

- (void)displayHintOnView:(UIView *)view withDisplayView:(UIView *)displayView animated:(BOOL)animated;
- (void) displayOnView:(UIView *)view animated:(BOOL)animated;
- (void) dismissAnimated:(BOOL)animated wasSeen:(BOOL)wasSeen;

@property (nonatomic, copy) void (^dismissAction)(BOOL wasSeen);

@end
