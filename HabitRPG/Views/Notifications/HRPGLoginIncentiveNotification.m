//
//  HRPGLoginIncentiveNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 20/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGLoginIncentiveNotification.h"
#import "HRPGLoginIncentiveOverlayView.h"
#import "KLCPopup.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@implementation HRPGLoginIncentiveNotification

- (void)displayNotification:(void (^)())completionBlock {
    NSArray *nibViews =
    [[NSBundle mainBundle] loadNibNamed:@"HRPGLoginIncentiveOverlayView" owner:self options:nil];
    HRPGLoginIncentiveOverlayView *overlayView = [nibViews objectAtIndex:0];

    NSInteger nextRewardIn = [self.notification.data[@"nextRewardAt"] integerValue] - [self.user.loginIncentives integerValue];
    
    if (self.notification.data[@"reward"]) {
        [overlayView setReward:self.notification.data[@"rewardKey"][0] withTitle:self.notification.data[@"message"] withMessage:[NSString stringWithFormat:NSLocalizedString(@"You have earned a %@ for being committed to improving your life.", nil), self.notification.data[@"rewardText"]] withDaysUntilNext:nextRewardIn];
        
        overlayView.dismissAction = ^() {
            if (completionBlock) {
                completionBlock();
            }
        };
        [overlayView sizeToFit];
        
        KLCPopup *popup = [KLCPopup popupWithContentView:overlayView
                                                showType:KLCPopupShowTypeBounceIn
                                             dismissType:KLCPopupDismissTypeBounceOut
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:NO];
        
        [popup show];
    } else {
        NSString *nextUnlock;
        if (nextRewardIn== 1) {
            nextUnlock = NSLocalizedString(@"Your next prize unlocks in 1 Check-In.", nil);
        } else {
            nextUnlock = [NSString stringWithFormat:NSLocalizedString(@"Your next prize unlocks in %d Check-Ins", nil), nextRewardIn];
        }
        [ToastManager showWithText:nextUnlock color:ToastColorBlue];
    }
}

@end
