//
//  HRPGQRCodeView.h
//  Habitica
//
//  Created by Phillip Thelen on 05/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AvatarProtocol;

@interface HRPGQRCodeView : UIView

@property (nonatomic) NSString *userID;

- (void)setAvatarViewWithUser:(id<AvatarProtocol>)user;

@property (nonatomic) void (^shareAction)();

@end
