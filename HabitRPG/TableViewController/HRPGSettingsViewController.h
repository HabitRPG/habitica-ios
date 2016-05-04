//
//  HRPGSettingsViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 13/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"
#import "XLFormViewController.h"

@interface HRPGSettingsViewController : XLFormViewController <UIAlertViewDelegate>
@property NSString *username;
@end
