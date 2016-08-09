//
//  HRPGQRCodeView.h
//  Habitica
//
//  Created by Phillip Thelen on 05/08/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface HRPGQRCodeView : UIView

@property (nonatomic) NSString *text;

- (void)setAvatarViewWithUser:(User *)user;

@end
