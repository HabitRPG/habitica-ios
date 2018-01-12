//
//  HRPGChatTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGChatTableViewCell.h"
#import <DateTools/DateTools.h>
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"
#import "NSString+Emoji.h"


@interface HRPGChatTableViewCell ()

@property BOOL isOwnMessage;
@property BOOL isPrivateMessage;
@property BOOL isModerator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extraButtonsHeightContraint;
@end

@implementation HRPGChatTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandCell:)];
        [self.contentView removeGestureRecognizer:self.contentView.gestureRecognizers[0]];
        [self.messageTextView addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
        tapRecognizer.cancelsTouchesInView = NO;
        [self.contentView addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *profileTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayProfile:)];
    [self.usernameLabel addGestureRecognizer:profileTapRecognizer];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandCell:)];
    tapRecognizer.delegate = self;
    [self.messageTextView addGestureRecognizer:tapRecognizer];
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.contentInset = UIEdgeInsetsZero;
    self.messageTextView.font = [CustomFontMetrics scaledSystemFontOfSize:15 compatibleWith:nil];
    
}

- (void)displayProfile:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.profileAction) {
        self.profileAction();
    }
}

- (void)expandCell:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.expandAction) {
        self.expandAction();
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (IBAction)plusOneButtonTapped:(id)sender {
    if (self.isOwnMessage) {
        return;
    }
    if (self.plusOneAction) {
        self.plusOneAction();
    }
}

- (IBAction)replyButtonTapped:(id)sender {
    if (self.replyAction) {
        self.replyAction();
    }
}

- (IBAction)reportButtonTapped:(id)sender {
    if (self.flagAction) {
        self.flagAction();
    }
}
- (IBAction)deleteButtonTapped:(id)sender {
    if (self.deleteAction) {
        self.deleteAction();
    }
}
- (IBAction)copyButtonTapped:(id)sender {
    if (self.copyAction) {
        self.copyAction();
    }
}

- (void)configureForMessage:(ChatMessage *)message
                 withUserID:(NSString *)userID
               withUsername:(NSString *)username
                isModerator:(BOOL)isModerator
                 isExpanded:(BOOL)isExpanded {
    self.isExpanded = isExpanded;
    self.backgroundColor = [UIColor whiteColor];
    self.leftMarginConstraint.constant = 8;
    self.isPrivateMessage = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.isModerator = isModerator;
    if (message.user) {
        self.usernameLabel.text = [message.user stringByReplacingEmojiCheatCodesWithUnicode];
        self.usernameLabel.contributorLevel = [message.contributorLevel integerValue];
        self.messageTextView.textColor = [UIColor gray10];
    } else {
        self.usernameLabel.text = nil;
        self.backgroundColor = [UIColor red500];
        self.messageTextView.textColor = [UIColor red50];
    }
    
    [self.plusOneButton setTitleColor:[UIColor gray300] forState:UIControlStateNormal];
    [self.plusOneButton setTintColor:[UIColor gray300]];
    BOOL wasLiked = NO;
    if (message.likes.count > 0) {
        [self.plusOneButton setTitle:[NSString stringWithFormat:@" +%lu", (unsigned long)message.likes.count] forState:UIControlStateNormal];
        for (ChatMessageLike *like in message.likes) {
            if ([like.userID isEqualToString:userID]) {
                [self.plusOneButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
                [self.plusOneButton setTintColor:[UIColor purple400]];
                wasLiked = YES;
                break;
            }
        }
    } else {
        [self.plusOneButton setTitle:nil forState:UIControlStateNormal];
        [self.plusOneButton setTitleColor:[UIColor gray50] forState:UIControlStateNormal];
    }
    [self.plusOneButton setImage:[HabiticaIcons imageOfChatLikeIconWithWasLiked:wasLiked] forState:UIControlStateNormal];

    self.timeLabel.text = message.timestamp.timeAgoSinceNow;
    if (message.attributedText.length > 0) {
        self.messageTextView.attributedText = message.attributedText;
    } else {
        self.messageTextView.text = message.text;
    }
    self.isOwnMessage = [message.uuid isEqualToString:userID];
    [self.reportButton setHidden:self.isOwnMessage];
    [self.deleteButton setHidden:!self.isOwnMessage ];
    if (self.isOwnMessage) {
        self.leftMarginConstraint.constant = 64;
    }
    
    [self showHideExtraButtons:isExpanded];
        
    if ([message.text rangeOfString:[NSString stringWithFormat:@"@%@", username]].location !=
        NSNotFound) {
        self.messageWrapper.backgroundColor = [UIColor purple600];
    }
}

- (void)configureForInboxMessage:(InboxMessage *)message
                        withUser:(User *)thisUser
                      isExpanded:(BOOL)isExpanded {
    self.isExpanded = isExpanded;
    self.backgroundColor = [UIColor whiteColor];
    self.leftMarginConstraint.constant = 8;
    self.isPrivateMessage = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    [self.plusOneButton setHidden:YES];
    NSInteger contributorLevel;
    if ([message.sent boolValue]) {
        self.usernameLabel.text = [thisUser.username stringByReplacingEmojiCheatCodesWithUnicode];
        contributorLevel = [thisUser.contributorLevel integerValue];
    } else {
        self.usernameLabel.text = [message.username stringByReplacingEmojiCheatCodesWithUnicode];
        contributorLevel = [message.contributorLevel integerValue];
    }
    self.usernameLabel.contributorLevel = contributorLevel;
    self.messageTextView.textColor = [UIColor blackColor];

    self.timeLabel.text = message.timestamp.timeAgoSinceNow;
    if (message.attributedText.length > 0) {
        self.messageTextView.attributedText = message.attributedText;
    } else {
        self.messageTextView.text = message.text;
    }

    self.plusOneButton.hidden = YES;
    self.isOwnMessage = [message.sent boolValue];
    [self.reportButton setHidden:self.isOwnMessage];
    [self.deleteButton setHidden:!self.isOwnMessage ];
    
    [self showHideExtraButtons:isExpanded];

    if (self.isOwnMessage) {
        self.leftMarginConstraint.constant = 64;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.plusOneButton.frame, [touch locationInView:self.contentView])) {
        return NO;  // ignore the touch
    }
    if (CGRectContainsPoint(self.messageTextView.frame, [touch locationInView:self.contentView])) {
        NSLayoutManager *layoutManager = self.messageTextView.layoutManager;
        CGPoint location = [touch locationInView:self.messageTextView];
        location.x -= self.messageTextView.textContainerInset.left;
        location.y -= self.messageTextView.textContainerInset.top;

        NSUInteger characterIndex;
        characterIndex = [layoutManager characterIndexForPoint:location
                                               inTextContainer:self.messageTextView.textContainer
                      fractionOfDistanceBetweenInsertionPoints:NULL];

        if (characterIndex < self.messageTextView.textStorage.length) {
            NSRange range;
            NSDictionary *attributes =
                [self.messageTextView.textStorage attributesAtIndex:characterIndex
                                                     effectiveRange:&range];
            if (attributes[@"NSLink"]) {
                return NO;
            }
        }
    }
    if (CGRectContainsPoint(self.usernameLabel.frame, [touch locationInView:self.contentView])) {
        return NO;
    }
    if (CGRectContainsPoint(self.extraButtonsStackView.frame, [touch locationInView:self.contentView])) {
        return NO;
    }
    return YES;  // handle the touch
}

- (void)showHideExtraButtons:(BOOL)shouldShow {
    [self.extraButtonsStackView setHidden:!shouldShow];
    if (shouldShow) {
        self.extraButtonsHeightContraint.constant = 36;
    } else {
        self.extraButtonsHeightContraint.constant = 0;
    }
}

@end
