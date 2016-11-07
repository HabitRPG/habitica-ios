//
//  HRPGStreakAchievementNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 03/11/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGStreakAchievementNotification.h"
#import "HRPGImageOverlayView.h"
#import "HRPGAppDelegate.h"
#import "HRPGSharingManager.h"
#import "UIView+Screenshot.h"

@implementation HRPGStreakAchievementNotification

- (void)displayNotification:(void (^)())completionBlock {
    NSArray *nibViews =
    [[NSBundle mainBundle] loadNibNamed:@"HRPGImageOverlayView" owner:self options:nil];
    HRPGImageOverlayView *overlayView = [nibViews objectAtIndex:0];
    overlayView.imageWidth = 140;
    overlayView.imageHeight = 147;
    [self.user setAvatarSubview:overlayView.imageView
                showsBackground:YES
                     showsMount:YES
                       showsPet:YES];
    overlayView.titleText = NSLocalizedString(@"You earned a streak achievement!", nil);
    overlayView.descriptionText = NSLocalizedString(
                                                     @"You've completed your Daily for 21 days in a row! Amazing job. Don't break the streak!", nil);
    overlayView.dismissButtonText = NSLocalizedString(@"Great!", nil);
    [overlayView setAchievementWithName:@"achievement-thermometer"];
    UIImageView *__weak weakAvatarView = overlayView.imageView;
    overlayView.shareAction = ^() {
        HRPGAppDelegate *del = (HRPGAppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *activeViewController =
        del.window.visibleViewController;
        [HRPGSharingManager shareItems:@[
                                         [
                                           NSLocalizedString(
                                                             @"I earned a new achievement in Habitica! ",
                                                             nil)
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
