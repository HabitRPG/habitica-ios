//
//  HRPGDropsEnabledNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 03/11/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGDropsEnabledNotification.h"
#import "HRPGImageOverlayView.h"
#import "HRPGAppDelegate.h"
#import "KLCPopup.h"
#import "Habitica-Swift.h"

@implementation HRPGDropsEnabledNotification

- (void)displayNotification:(void (^)(void))completionBlock {
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
    overlayView.titleText = objcL10n.unlockDropsTitle;
    overlayView.descriptionText = objcL10n.unlockDropsDescription;
    overlayView.dismissButtonText = objcL10n.great;
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
