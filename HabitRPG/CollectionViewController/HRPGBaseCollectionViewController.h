//
//  HRPGBBaseCollectionViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 13/07/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGCollectionViewController.h"

@interface HRPGBaseCollectionViewController : HRPGCollectionViewController

@property CGFloat screenWidth;
@property BOOL hidesTopBar;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

@end
