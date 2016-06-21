//
//  HRPGChatTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGChatTableViewCell.h"
#import <DateTools/DateTools.h>
#import "UIColor+Habitica.h"

@interface HRPGChatTableViewCell ()

@property BOOL isOwnMessage;
@property BOOL isPrivateMessage;
@property BOOL isModerator;
@end

@implementation HRPGChatTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMenu:)];
        tapRecognizer.delegate = self;
        tapRecognizer.cancelsTouchesInView = NO;
        [self.contentView removeGestureRecognizer:self.contentView.gestureRecognizers[0]];
        [self addGestureRecognizer:tapRecognizer];
        self.plusOneButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *buttonTapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(plusOneButtonTapped:)];
        [self.plusOneButton addGestureRecognizer:buttonTapRecognizer];
        [self bringSubviewToFront:self.plusOneButton];

        self.messageTextView.textContainerInset = UIEdgeInsetsZero;
        self.messageTextView.contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL returnValue = (action == @selector(copy:) || action == @selector(profileMenuItemSelected:));
    if (self.isOwnMessage || self.isModerator || self.isPrivateMessage) {
        returnValue =  (returnValue || action == @selector(delete:));
    }
    if (!self.isOwnMessage) {
        returnValue = (returnValue || action == @selector(reply:) || action == @selector(flag:));
    }
    return returnValue;
}

- (void)displayMenu:(UITapGestureRecognizer *)gestureRecognizer {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *profileMenuItem =
        [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Profile", nil)
                                   action:@selector(profileMenuItemSelected:)];
    NSMutableArray *menuItems = [NSMutableArray arrayWithObjects:profileMenuItem, nil];
    if (self.replyAction) {
        UIMenuItem *replyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil)
                                                               action:@selector(reply:)];
        [menuItems addObject:replyMenuItem];
    }
    if (self.flagAction) {
        UIMenuItem *flagMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Report", nil)
                                                              action:@selector(flag:)];
        [menuItems addObject:flagMenuItem];
    }
    [menu setMenuItems:menuItems];
    [menu update];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)profileMenuItemSelected:(id)sender {
    if (self.profileAction) {
        self.profileAction();
    }
}

- (void)copy:(id)sender {
    if (self.messageTextView.attributedText) {
        NSString *message = [self.detailTextLabel.attributedText string];
        if (message) {
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            pboard.string = message;
        }
    }
}

- (void)flag:(id)sender {
    if (self.flagAction) {
        self.flagAction();
    }
}

- (void)reply:(id)sender {
    if (self.replyAction) {
        self.replyAction();
    }
}

- (void) delete:(id)sender {
    if (self.deleteAction) {
        self.deleteAction();
    }
}

- (IBAction)plusOneButtonTapped:(id)sender {
    if (self.isOwnMessage) {
        return;
    }
    if (self.plusOneAction) {
        self.plusOneAction();
    }
}

- (void)configureForMessage:(ChatMessage *)message
                 withUserID:(NSString *)userID
               withUsername:(NSString *)username
                isModerator:(BOOL)isModerator {
    self.isPrivateMessage = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.isModerator = isModerator;
    if (message.user) {
        self.usernameWrapper.hidden = NO;
        self.usernameLabel.text = message.user;
        self.usernameWrapper.backgroundColor = [self contributorColor:[message.contributorLevel integerValue]];
        self.indicatorImageViewWidthConstraint.constant = 21;
        if ([message.contributorLevel integerValue] == 8) {
            self.modIndicatorImageView.image = [UIImage imageNamed:@"star"];
        } else if ([message.contributorLevel integerValue] == 9) {
            self.modIndicatorImageView.image = [UIImage imageNamed:@"crown"];
        } else {
            self.modIndicatorImageView.image = nil;
            self.indicatorImageViewWidthConstraint.constant = 8;
        }
        self.messageTextView.textColor = [UIColor blackColor];
    } else {
        self.usernameLabel.text = nil;
        self.usernameWrapper.hidden = YES;
        self.backgroundColor = [UIColor red500];
        self.messageTextView.textColor = [UIColor red50];
        self.plusOneButton.hidden = YES;
    }

    self.timeLabel.text = message.timestamp.timeAgoSinceNow;
    self.messageTextView.attributedText = message.attributedText;

    self.usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    [self.plusOneButton
        setTitle:[NSString stringWithFormat:@"+%lu", (unsigned long)message.likes.count]
        forState:UIControlStateNormal];
    if (message.likes.count > 0) {
        self.plusOneButton.backgroundColor = [UIColor gray100];
        [self.plusOneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.plusOneButton.backgroundColor = [UIColor gray400];
        [self.plusOneButton setTitleColor:[UIColor gray50] forState:UIControlStateNormal];
    }
    for (ChatMessageLike *like in message.likes) {
        if ([like.userID isEqualToString:userID]) {
            self.plusOneButton.backgroundColor = [UIColor purple100];
            break;
        }
    }
    [self.plusOneButton setTitleColor:[UIColor purple300] forState:UIControlStateSelected];
    if (message.user) {
        self.plusOneButtonWidthConstraint.constant =
            self.plusOneButton.intrinsicContentSize.width + 8;
    } else {
        self.plusOneButtonWidthConstraint.constant = 0;
    }
    self.isOwnMessage = [message.uuid isEqualToString:userID];
    if (self.isOwnMessage) {
        self.backgroundColor = [UIColor gray500];
    }
    if ([message.text rangeOfString:[NSString stringWithFormat:@"@%@", username]].location !=
        NSNotFound) {
        self.backgroundColor = [UIColor purple600];
    }
}

- (void)configureForInboxMessage:(InboxMessage *)message
                        withUser:(User *)thisUser {
    self.isPrivateMessage = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.usernameWrapper.hidden = NO;
    NSInteger contributorLevel;
    if ([message.sent boolValue]) {
        self.usernameLabel.text = thisUser.username;
        contributorLevel = [thisUser.contributorLevel integerValue];
    } else {
        self.usernameLabel.text = message.username;
        contributorLevel = [message.contributorLevel integerValue];
    }
    self.usernameWrapper.backgroundColor = [self contributorColor:contributorLevel];
    self.indicatorImageViewWidthConstraint.constant = 21;
    if (contributorLevel == 8) {
        self.modIndicatorImageView.image = [UIImage imageNamed:@"star"];
    } else if (contributorLevel == 9) {
        self.modIndicatorImageView.image = [UIImage imageNamed:@"crown"];
    } else {
        self.modIndicatorImageView.image = nil;
        self.indicatorImageViewWidthConstraint.constant = 8;
    }
    self.messageTextView.textColor = [UIColor blackColor];

    self.timeLabel.text = message.timestamp.timeAgoSinceNow;
    self.messageTextView.attributedText = message.attributedText;
    
    self.usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    self.plusOneButton.hidden = YES;
    self.plusOneButtonWidthConstraint.constant = 0;
    
    self.isOwnMessage = [message.sent boolValue];
    if (self.isOwnMessage) {
        self.backgroundColor = [UIColor gray500];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.plusOneButton.frame, [touch locationInView:self])) {
        return NO;  // ignore the touch
    }
    if (CGRectContainsPoint(self.messageTextView.frame, [touch locationInView:self])) {
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
    return YES;  // handle the touch
}


- (UIColor *)contributorColor:(NSInteger)contributorLevel {
    switch (contributorLevel) {
        case 1:
            return [UIColor colorWithRed:0.941 green:0.380 blue:0.549 alpha:1.000];
        case 2:
            return [UIColor colorWithRed:0.659 green:0.118 blue:0.141 alpha:1.000];
        case 3:
            return [UIColor colorWithRed:0.984 green:0.098 blue:0.031 alpha:1.000];
        case 4:
            return [UIColor colorWithRed:0.992 green:0.506 blue:0.031 alpha:1.000];
        case 5:
            return [UIColor colorWithRed:0.806 green:0.779 blue:0.284 alpha:1.000];
        case 6:
            return [UIColor colorWithRed:0.333 green:1.000 blue:0.035 alpha:1.000];
        case 7:
            return [UIColor colorWithRed:0.071 green:0.592 blue:1.000 alpha:1.000];
        case 8:
            return [UIColor colorWithRed:0.055 green:0.000 blue:0.876 alpha:1.000];
        case 9:
            return [UIColor colorWithRed:0.455 green:0.000 blue:0.486 alpha:1.000];
        default:
            return [UIColor grayColor];
    }
}

@end
