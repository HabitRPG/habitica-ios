//
//  HRPGGemPurchaseView.m
//  Habitica
//
//  Created by Phillip Thelen on 06/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGGemPurchaseView.h"
#import "HRPGPurchaseLoadingButton.h"

@interface HRPGGemPurchaseView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promoGemsSpace;
@property(nonatomic) void (^promoTapEvent)();

@end

@implementation HRPGGemPurchaseView

- (void)setGemAmount:(NSInteger)amount {
    self.amountLabel.text = [@(amount) stringValue];
    switch (amount) {
        case 4:
            self.imageView.image = [UIImage imageNamed:@"4_gems"];
            break;
        case 21:
            self.imageView.image = [UIImage imageNamed:@"21_gems"];
            break;
        case 42:
            self.imageView.image = [UIImage imageNamed:@"42_gems"];
            break;
        case 84:
            self.imageView.image = [UIImage imageNamed:@"84_gems"];
            break;
            
        default:
            break;
    }
}

- (void)setPrice:(NSString *)price {
    [self.purchaseButton setText:price];
}

- (void)setPurchaseTap:(void (^)(HRPGPurchaseLoadingButton *))purchaseTap {
    self.purchaseButton.onTouchEvent = purchaseTap;
}

- (void)showSeedsPromo:(BOOL)showPromo {
    if (showPromo) {
        self.seeds_promo.hidden = NO;
        self.promoHeight.constant = 28;
        self.promoGemsSpace.constant = 16;
    } else {
        self.seeds_promo.hidden = YES;
        self.promoHeight.constant = 0;
        self.promoGemsSpace.constant = 0;
    }
}

@end
