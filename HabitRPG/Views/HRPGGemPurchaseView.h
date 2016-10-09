//
//  HRPGGemPurchaseView.h
//  Habitica
//
//  Created by Phillip Thelen on 06/10/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGPurchaseLoadingButton.h"

@interface HRPGGemPurchaseView : UICollectionViewCell

- (void) setGemAmount:(NSInteger)amount;
- (void) setPrice:(NSString *)price;

- (void) setPurchaseTap:(void (^)(HRPGPurchaseLoadingButton *button))purchaseTap;

@property (weak, nonatomic) IBOutlet HRPGPurchaseLoadingButton *purchaseButton;

@end
