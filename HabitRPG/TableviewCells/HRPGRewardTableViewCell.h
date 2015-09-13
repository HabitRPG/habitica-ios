//
//  HRPGRewardTableViewCell.h
//  Habitica
//
//  Created by Phillip Thelen on 13/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaReward.h"

@interface HRPGRewardTableViewCell : UITableViewCell

- (void) configureForReward:(MetaReward *)reward withGoldOwned:(NSNumber *)gold;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleNotesConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UIView *buyButton;
@property (weak, nonatomic) IBOutlet UIView *buyView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

- (void)onPurchaseTap:(void (^)())actionBlock;


@end
