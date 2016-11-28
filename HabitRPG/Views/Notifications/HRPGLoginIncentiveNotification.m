//
//  HRPGLoginIncentiveNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 20/11/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGLoginIncentiveNotification.h"
#import "HRPGLoginIncentiveOverlayView.h"
#import "KLCPopup.h"

@implementation HRPGLoginIncentiveNotification

- (void)displayNotification:(void (^)())completionBlock {
    NSArray *nibViews =
    [[NSBundle mainBundle] loadNibNamed:@"HRPGLoginIncentiveOverlayView" owner:self options:nil];
    HRPGLoginIncentiveOverlayView *overlayView = [nibViews objectAtIndex:0];

    if (self.notification.data[@"reward"]) {
        [overlayView setReward:self.notification.data[@"rewardKey"][0] withTitle:self.notification.data[@"message"] withMessage:[NSString stringWithFormat:NSLocalizedString(@"You have earned a %@ for being committed to improving your life.", nil), self.notification.data[@"rewardText"]] withDaysUntilNext:self.notification.data[@"nextRewardAt"]];
    } else {
        [overlayView setNoRewardWithMessage:self.notification.data[@"message"] withDaysUntilNext:self.notification.data[@"nextRewardAt"]];
    }
    
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
}

@end
