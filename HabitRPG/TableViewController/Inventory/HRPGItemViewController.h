//
//  HRPGItemViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"
#import "HRPGCoreDataDataSourceDelegate.h"

@interface HRPGItemViewController
    : HRPGBaseViewController<UIActionSheetDelegate, HRPGCoreDataDataSourceDelegate>

@property(strong) NSString *itemType;
@property BOOL shouldDismissAfterAction;

@end
