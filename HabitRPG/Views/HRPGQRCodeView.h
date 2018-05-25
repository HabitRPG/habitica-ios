//
//  HRPGQRCodeView.h
//  Habitica
//
//  Created by Phillip Thelen on 05/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGQRCodeView : UIView

@property (nonatomic) NSString *userID;

- (void)setAvatarViewWithUser:(NSObject *)user;

@property (nonatomic) void (^shareAction)();

@end
