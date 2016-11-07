//
//  HRPGDropsEnabledNotification.m
//  Habitica
//
//  Created by Phillip Thelen on 03/11/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGDropsEnabledNotification.h"
#import "HRPGImageOverlayView.h"
#import "HRPGAppDelegate.h"

@implementation HRPGDropsEnabledNotification

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
    overlayView.titleText = NSLocalizedString(@"You unlocked the drop system!", nil);
    overlayView.descriptionText = NSLocalizedString(
                                                    @"You've unlocked the Drop System! Now when you complete tasks, you have a small chance of finding an item, including eggs, potions, and food!", nil);
    overlayView.dismissButtonText = NSLocalizedString(@"Great!", nil);
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
