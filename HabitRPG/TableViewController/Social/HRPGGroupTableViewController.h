//
//  HRPGChatTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HRPGBaseViewController.h"
#import "User.h"

@interface HRPGGroupTableViewController
    : HRPGBaseViewController<NSFetchedResultsControllerDelegate, UIActionSheetDelegate,
                             UITextViewDelegate>

@property User *user;

@property NSString *groupID;
@property(nonatomic) Group *group;
@property(strong, nonatomic) NSFetchedResultsController *chatMessagesFRC;

- (int)chatSectionIndex;
- (bool)listMembers;
- (void)fetchGroup;
- (void)refresh;
@end
