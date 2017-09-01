//
//  HRPGTypingLabel.h
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGTypingLabel : UITextView

@property(nonatomic) CGFloat typingSpeed;

@property(nonatomic, copy) void (^finishedAction)();


- (void)setText:(NSString *)text startAnimating:(BOOL)startAnimating;

- (void)startAnimating;

@end
