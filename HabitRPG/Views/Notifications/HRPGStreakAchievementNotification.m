//
//  HRPGStreakAchievementNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 03/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGStreakAchievementNotification.h"
#import "HRPGImageOverlayView.h"
#import "HRPGAppDelegate.h"
#import "HRPGSharingManager.h"
#import "UIView+Screenshot.h"
#import "Habitica-Swift.h"

@implementation HRPGStreakAchievementNotification

- (void)displayNotification:(void (^)())completionBlock {
    NSArray *nibViews =
    [[NSBundle mainBundle] loadNibNamed:@"HRPGImageOverlayView" owner:self options:nil];
    HRPGImageOverlayView *overlayView = [nibViews objectAtIndex:0];
    overlayView.imageWidth = 140;
    overlayView.imageHeight = 147;
    //TODO: FIX
    /*[self.user setAvatarSubview:overlayView.imageView
                showsBackground:YES
                     showsMount:YES
                       showsPet:YES];*/
    overlayView.titleText = objcL10n.streakAchievementTitle;
    overlayView.descriptionText = objcL10n.streakAchievementDescription;
    overlayView.dismissButtonText = objcL10n.great;
    [overlayView setAchievementWithName:@"achievement-thermometer"];
    UIImageView *__weak weakAvatarView = overlayView.imageView;
    overlayView.shareAction = ^() {
        HRPGAppDelegate *del = (HRPGAppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *activeViewController =
        del.window.visibleViewController;
        [HRPGSharingManager shareItems:@[
                                         [
                                           objcL10n.earnedAchievementShare
                                          stringByAppendingString:@" https://habitica.com/social/achievement"],
                                         [weakAvatarView pb_takeScreenshot]
                                         ]
          withPresentingViewController:activeViewController
                        withSourceView:nil];
    };
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
