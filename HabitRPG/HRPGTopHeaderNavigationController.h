//
//  HRPGTopHeaderNavigationController.h
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

@import UIKit;

@interface HRPGTopHeaderNavigationController : UINavigationController <UIScrollViewDelegate>

- (CGFloat) getContentInset;
- (CGFloat) getContentOffset;
@property BOOL isTopHeaderVisible;
@property (nonatomic) CGFloat previousScrollViewYOffset;



@end
