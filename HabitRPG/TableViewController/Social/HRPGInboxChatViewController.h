//
//  HRPGInboxChatViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlackTextViewController/SLKTextViewController.h>

@interface HRPGInboxChatViewController : SLKTextViewController

@property NSString *userID;
@property NSString *username;
@property NSString *displayName;
@property BOOL isPresentedModally;
@property BOOL isScrolling;

- (void)setTitleWithUsername:(NSString * _Nullable)username;

@end
