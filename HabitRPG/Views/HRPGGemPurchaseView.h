//
//  HRPGGemPurchaseView.h
//  Habitica
//
//  Created by Phillip Thelen on 06/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGPurchaseLoadingButton.h"

@interface HRPGGemPurchaseView : UICollectionViewCell

- (void) setGemAmount:(NSInteger)amount;
- (void) setPrice:(NSString *)price;

@property (weak, nonatomic) IBOutlet HRPGPurchaseLoadingButton *purchaseButton;

@end
