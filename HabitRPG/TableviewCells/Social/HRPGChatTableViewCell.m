//
//  HRPGChatTableViewCell.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGChatTableViewCell.h"
#import <DateTools/DateTools.h>
#import "User.h"
#import "ChatMessageLike.h"
#import "UIColor+Habitica.h"

@interface HRPGChatTableViewCell()

@property bool isOwnMessage;

@end

@implementation HRPGChatTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMenu:)];
        tapRecognizer.delegate = self;
        tapRecognizer.cancelsTouchesInView = NO;
        [self.contentView removeGestureRecognizer:self.contentView.gestureRecognizers[0]];
        [self addGestureRecognizer:tapRecognizer];
        self.plusOneButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *buttonTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(plusOneButtonTapped:)];
        [self.plusOneButton addGestureRecognizer:buttonTapRecognizer];
        [self bringSubviewToFront:self.plusOneButton];
        
        self.messageTextView.textContainerInset = UIEdgeInsetsZero;
        self.messageTextView.contentInset = UIEdgeInsetsZero;
    }
    return self;
}


-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (self.isOwnMessage) {
        return (action == @selector(copy:) || action == @selector(profileMenuItemSelected:) || action == @selector(delete:));
    } else {
        return (action == @selector(copy:) || action == @selector(profileMenuItemSelected:) || action == @selector(reply:) || action == @selector(flag:));
    }
}

- (void) displayMenu:(UITapGestureRecognizer *)gestureRecognizer {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *profileMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Profile", nil) action:@selector(profileMenuItemSelected:)];
    UIMenuItem *replyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil) action:@selector(reply:)];
    UIMenuItem *flagMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Flag", nil) action:@selector(flag:)];
    [menu setMenuItems: @[profileMenuItem, replyMenuItem, flagMenuItem]];
    [menu update];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

-(void) profileMenuItemSelected: (id) sender {
    if (self.profileAction) {
        self.profileAction();
    }
}

-(void) copy:(id)sender {
    if (self.messageTextView.attributedText) {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = [self.detailTextLabel.attributedText string];
    }
}

-(void) flag:(id)sender {
    if (self.flagAction) {
        self.flagAction();
    }
}

-(void) reply:(id)sender {
    if (self.replyAction) {
        self.replyAction();
    }
}

-(void) delete:(id)sender {
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

- (void)configureForMessage:(ChatMessage *)message withUserID:(NSString *)userID withUsername:(NSString *)username {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (message.user) {
        self.usernameWrapper.hidden = NO;
        self.usernameLabel.text = message.user;
        self.usernameWrapper.backgroundColor = [message contributorColor];
        self.indicatorImageViewWidthConstraint.constant = 21;
        if ([message.contributorLevel integerValue] == 8) {
            self.modIndicatorImageView.image = [UIImage imageNamed:@"star"];
        } else if ([message.contributorLevel integerValue] == 9) {
            self.modIndicatorImageView.image = [UIImage imageNamed:@"crown"];
        } else {
            self.modIndicatorImageView.image = nil;
            self.indicatorImageViewWidthConstraint.constant = 8;
        }
    } else {
        self.usernameLabel.text = nil;
        self.usernameWrapper.hidden = YES;
    }
    
    self.timeLabel.text = message.timestamp.timeAgoSinceNow;
    self.messageTextView.attributedText = message.attributedText;
    
    self.usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    [self.plusOneButton setTitle:[NSString stringWithFormat:@"+%lu", (unsigned long)message.likes.count] forState:UIControlStateNormal];
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
    self.plusOneButtonWidthConstraint.constant = self.plusOneButton.intrinsicContentSize.width + 8;
    
    self.isOwnMessage = [message.uuid isEqualToString:userID];
    if (self.isOwnMessage) {
        self.backgroundColor = [UIColor gray500];
    }
    if ([message.text containsString:[NSString stringWithFormat:@"@%@", username]]) {
        self.backgroundColor = [UIColor purple600];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    


    [self setNeedsLayout];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.plusOneButton.superview != nil) {
        if (CGRectContainsPoint(self.plusOneButton.frame, [touch locationInView:self])) {
            return NO; // ignore the touch
        }
    }
    return YES; // handle the touch
}

@end
