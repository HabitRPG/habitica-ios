//
//  HRPGTopHeaderNavigationController.h
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

@import UIKit;

@protocol TopHeaderNavigationControllerProtocol;

typedef enum HRPGTopHeaderState : NSInteger {
    HRPGTopHeaderStateVisible,
    HRPGTopHeaderStateHidden,
    HRPGTopHeaderStateScrolling
} HRPGTopHeaderState;

@interface HRPGTopHeaderNavigationController : UINavigationController<UIGestureRecognizerDelegate, TopHeaderNavigationControllerProtocol>

- (CGFloat)getContentInset;
- (CGFloat)getContentOffset;
@property (nonatomic, readonly) CGFloat contentInset;
@property (nonatomic, readonly) CGFloat contentOffset;

@property (nonatomic) UIColor *navbarHiddenColor;
@property (nonatomic) UIColor *navbarVisibleColor;

@property (nonatomic) UIColor *defaultNavbarHiddenColor;
@property (nonatomic) UIColor *defaultNavbarVisibleColor;

@property (nonatomic) BOOL hideNavbar;

@property(nonatomic) HRPGTopHeaderState state;

@property (nonatomic) BOOL shouldHideTopHeader;
- (void)setShouldHideTopHeader:(BOOL)shouldHideTopHeader animated:(BOOL)animated;

- (void)startFollowingScrollView:(UIScrollView *)scrollView;
- (void)stopFollowingScrollView;
- (void)scrollView:(UIScrollView *)scrollView scrolledToPosition:(CGFloat)position;

- (void)setAlternativeHeaderView:(UIView *)alternativeHeaderView;
- (void)removeAlternativeHeaderView;
@end
