//
//  HRPGCreatePartyViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 23/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "XLFormViewController.h"

@interface HRPGGroupFormViewController : XLFormViewController

@property(weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property Group *group;
@property BOOL editGroup;
@property NSString *groupType;
@end
