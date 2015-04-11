//
//  HRPGTopHeaderNavigationController.h
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGTopHeaderNavigationController : UINavigationController

@property BOOL isTopHeaderVisible;

- (CGFloat) getContentOffset;

- (void)hideTopBar;
- (void)showTopBar;

@end
