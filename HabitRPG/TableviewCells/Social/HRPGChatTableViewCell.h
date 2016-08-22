//
//  HRPGChatTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
#import "InboxMessage.h"

typedef NS_ENUM(NSInteger, HRPGChatTableViewCellType) {
    HRPGChatTableViewCellTypeGroup,
    HRPGChatTableViewCellTypeTavern,
    HRPGChatTableViewCellTypeParty
};

@interface HRPGChatTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property(weak, nonatomic) IBOutlet UIImageView *modIndicatorImageView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *indicatorImageViewWidthConstraint;
@property(weak, nonatomic) IBOutlet UIView *usernameWrapper;
@property(weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(weak, nonatomic) IBOutlet UITextView *messageTextView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *usernameHeightConstraint;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *usernameWidthConstraint;
@property(weak, nonatomic) IBOutlet UIButton *plusOneButton;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *plusOneButtonHeightConstraint;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *plusOneButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sendingLabel;

- (void)configureForMessage:(ChatMessage *)message
                 withUserID:(NSString *)userID
               withUsername:(NSString *)username
                isModerator:(BOOL)isModerator;

- (void)configureForInboxMessage:(InboxMessage *)message
                        withUser:(User *)thisUser;

@property(nonatomic) void (^profileAction)();
@property(nonatomic) void (^flagAction)();
@property(nonatomic) void (^replyAction)();
@property(nonatomic) void (^deleteAction)();
@property(nonatomic) void (^plusOneAction)();

@end
