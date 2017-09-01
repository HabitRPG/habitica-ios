//
//  HRPGGemHeaderNavigationController.h
//  Habitica
//
//  Created by Phillip Thelen on 10/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGTopHeaderNavigationController.h"

@interface HRPGGemHeaderNavigationController : UINavigationController

- (CGFloat)getContentInset;
- (CGFloat)getContentOffset;
@property(nonatomic) HRPGTopHeaderState state;

- (void)startFollowingScrollView:(UIScrollView *)scrollView;
- (void)stopFollowingScrollView;
- (void)scrollview:(UIScrollView *)scrollView scrolledToPosition:(CGFloat)position;

@end
