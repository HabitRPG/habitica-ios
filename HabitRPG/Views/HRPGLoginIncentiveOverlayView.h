//
//  HRPGLoginIncentiveOverlayView.h
//  Habitica
//
//  Created by Phillip Thelen on 20/11/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGLoginIncentiveOverlayView : UIView

- (void)setReward:(NSString *)imageName withTitle:(NSString *)title withMessage:(NSString *)message withDaysUntilNext:(NSNumber *) daysUntil;
- (void)setNoRewardWithMessage:(NSString *)message withDaysUntilNext:(NSNumber *) daysUntil;

@property(nonatomic) CGFloat imageHeight;
@property(nonatomic) CGFloat imageWidth;

@property(nonatomic) NSString *titleText;
@property(nonatomic) NSString *descriptionText;

@property(nonatomic) void (^dismissAction)();
@property(nonatomic) void (^shareAction)();

@end
