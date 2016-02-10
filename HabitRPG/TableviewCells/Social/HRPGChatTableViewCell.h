//
//  HRPGChatTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"

typedef NS_ENUM(NSInteger, HRPGChatTableViewCellType) {
    HRPGChatTableViewCellTypeGroup,
    HRPGChatTableViewCellTypeTavern,
    HRPGChatTableViewCellTypeParty
};

@interface HRPGChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *plusOneButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plusOneButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plusOneButtonWidthConstraint;

- (void)configureForMessage:(ChatMessage *) message withUserID:(NSString *)userID;

@property (nonatomic, copy) void (^profileAction)();
@property (nonatomic, copy) void (^flagAction)();
@property (nonatomic, copy) void (^replyAction)();
@property (nonatomic, copy) void (^deleteAction)();

@end
