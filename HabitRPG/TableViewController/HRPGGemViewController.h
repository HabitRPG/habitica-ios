//
//  HRPGGemViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"

@interface HRPGGemViewController : UITableViewController

@property BOOL displayNoGemLabel;

@property(nonatomic) HRPGManager *sharedManager;

@end
