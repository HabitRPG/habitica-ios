//
//  HRPGChatTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "User.h"
#import "HRPGBaseViewController.h"
#import "HRPGChatTableViewCell.h"

@interface HRPGGroupTableViewController : HRPGBaseViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITextViewDelegate>

@property User *user;

@property NSString *groupID;
@property (nonatomic) Group *group;
@property (strong, nonatomic) NSFetchedResultsController *chatMessagesFRC;

- (int) chatSectionIndex;
- (void)configureChatMessageCell:(HRPGChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) fetchGroup;
- (void) refresh;
@end
