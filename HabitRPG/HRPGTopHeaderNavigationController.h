//
//  HRPGTopHeaderNavigationController.h
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

@import UIKit;

typedef enum HRPGTopHeaderState : NSInteger {
    HRPGTopHeaderStateVisible,
    HRPGTopHeaderStateHidden,
    HRPGTopHeaderStateScrolling
} HRPGTopHeaderState;

@interface HRPGTopHeaderNavigationController : UINavigationController<UIGestureRecognizerDelegate>

- (CGFloat)getContentInset;
- (CGFloat)getContentOffset;
@property(nonatomic) HRPGTopHeaderState state;

- (void)startFollowingScrollView:(UIScrollView *)scrollView;
- (void)stopFollowingScrollView;
- (void)scrollview:(UIScrollView *)scrollView scrolledToPosition:(CGFloat)position;

- (void)setAlternativeHeaderView:(UIView *)alternativeHeaderView;
- (void)removeAlternativeHeaderView;
@end
