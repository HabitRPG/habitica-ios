//
//  HRPGArrayViewController.h
//  Habitica
//
//  Created by Phillip on 22/08/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGArrayViewController : UITableViewController

@property(nonatomic) NSArray *items;
@property NSInteger selectedIndex;

@end
