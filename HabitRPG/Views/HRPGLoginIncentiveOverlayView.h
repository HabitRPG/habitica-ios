//
//  HRPGLoginIncentiveOverlayView.h
//  Habitica
//
//  Created by Phillip Thelen on 20/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGLoginIncentiveOverlayView : UIView

- (void)setReward:(NSString *)imageName withTitle:(NSString *)title withMessage:(NSString *)message withDaysUntilNext:(NSInteger) daysUntil;

@property(nonatomic) CGFloat imageHeight;
@property(nonatomic) CGFloat imageWidth;

@property(nonatomic) NSString *titleText;
@property(nonatomic) NSString *descriptionText;

@property(nonatomic) void (^dismissAction)(void);
@property(nonatomic) void (^shareAction)(void);

@end
