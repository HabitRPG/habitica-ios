//
//  HRPGChatTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
#import "InboxMessage.h"

@class UsernameLabel;

typedef NS_ENUM(NSInteger, HRPGChatTableViewCellType) {
    HRPGChatTableViewCellTypeGroup,
    HRPGChatTableViewCellTypeTavern,
    HRPGChatTableViewCellTypeParty
};

@interface HRPGChatTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property BOOL isExpanded;

@property (weak, nonatomic) IBOutlet UIView *messageWrapper;
@property(weak, nonatomic) IBOutlet UsernameLabel *usernameLabel;
@property(weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(weak, nonatomic) IBOutlet UITextView *messageTextView;
@property(weak, nonatomic) IBOutlet UIButton *plusOneButton;
@property (weak, nonatomic) IBOutlet UIStackView *extraButtonsStackView;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMarginConstraint;

- (void)configureForMessage:(ChatMessage *)message
                 withUserID:(NSString *)userID
               withUsername:(NSString *)username
                isModerator:(BOOL)isModerator
                 isExpanded:(BOOL)isExpanded;

- (void)configureForInboxMessage:(InboxMessage *)message
                        withUser:(User *)thisUser
                      isExpanded:(BOOL)isExpanded;

@property(nonatomic) void (^profileAction)();
@property(nonatomic) void (^flagAction)();
@property(nonatomic) void (^replyAction)();
@property(nonatomic) void (^deleteAction)();
@property(nonatomic) void (^plusOneAction)();
@property(nonatomic) void (^copyAction)();
@property(nonatomic) void (^expandAction)();

@end
