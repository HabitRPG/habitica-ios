//
//  HRPGPurchaseLoadingButton.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HRPGPurchaseButtonStateLabel = 0,
    HRPGPurchaseButtonStateConfirm,
    HRPGPurchaseButtonStateLoading,
    HRPGPurchaseButtonStateDone
} HRPGPurchaseButtonState;

@interface HRPGPurchaseLoadingButton : UIView

@property (nonatomic) NSString *text;
@property (nonatomic) NSString *confirmText;
@property (nonatomic) NSString *doneText;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) HRPGPurchaseButtonState state;
@property (nonatomic, copy) void (^onTouchEvent)(HRPGPurchaseLoadingButton *purchaseButton);

@end
