//
//  HRPGGroupAboutTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 16/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HRPGBaseViewController.h"

@interface HRPGGroupAboutTableViewController : HRPGBaseViewController<UIAlertViewDelegate>

@property Group *group;
@property BOOL isLeader;

@end
