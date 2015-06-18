//
//  HRPGGoldView.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGoldView.h"
#import "HRPGAbbrevNumberLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HRPGGoldView ()

@property UIImageView *goldImageView;
@property HRPGAbbrevNumberLabel *goldLabel;
@property UIImageView *silverImageView;
@property HRPGAbbrevNumberLabel *silverLabel;
@property UIView *moneyView;
@property NSNumber *gold;

@end

@implementation HRPGGoldView



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.goldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, self.frame.size.height)];
        self.goldImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.goldImageView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/shop_gold.png"]];
        self.goldLabel = [[HRPGAbbrevNumberLabel alloc] initWithFrame:CGRectMake(26, 0, 100, self.frame.size.height)];
        self.goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [self.gold integerValue]];
        [self.goldLabel sizeToFit];
        
        
        self.silverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 + self.goldLabel.frame.size.width, 0, 25, self.frame.size.height)];
        self.silverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.silverImageView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/shop_silver.png"]];
        self.silverLabel = [[HRPGAbbrevNumberLabel alloc] initWithFrame:CGRectMake(30 + self.goldLabel.frame.size.width + 26, 0, 100, self.frame.size.height)];
        int silver = ([self.gold floatValue] - [self.gold integerValue]) * 100;
        self.silverLabel.text = [NSString stringWithFormat:@"%d", silver];
        [self.silverLabel sizeToFit];
        
        [self addSubview:self.goldLabel];
        [self addSubview:self.goldImageView];
        [self addSubview:self.silverImageView];
        [self addSubview:self.silverLabel];
    }
    
    return self;
}

- (void)updateView:(NSNumber *)newGold withDiffString:(NSString *)amount {
    NSNumber *gold = newGold;
    self.goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [gold integerValue]];
    [self.goldLabel sizeToFit];
    
    int silver = ([gold floatValue] - [gold integerValue]) * 100;
    self.silverLabel.text = [NSString stringWithFormat:@"%d", silver];
    self.silverLabel.frame = CGRectMake(30 + self.goldLabel.frame.size.width + 26, 0, 100, 16);
    
    [self.silverLabel sizeToFit];
    self.silverImageView.frame = CGRectMake(30 + self.goldLabel.frame.size.width, 0, 25, 22);

    if (amount) {
        //animate the gold change
        UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.goldLabel.frame.origin.y, self.goldLabel.frame.size.width + self.goldLabel.frame.origin.x, 16)];
        updateLabel.font = [UIFont systemFontOfSize:13.0f];
        updateLabel.textAlignment = NSTextAlignmentRight;
        updateLabel.text = amount;
        updateLabel.textColor = [UIColor redColor];
        [self.moneyView addSubview:updateLabel];
        [UIView animateWithDuration:0.3 animations:^() {
            updateLabel.frame = CGRectMake(0, 25, self.goldLabel.frame.size.width + self.goldLabel.frame.origin.x, 16);
            updateLabel.alpha = 0.0f;
        }                completion:^(BOOL completition) {
            [updateLabel removeFromSuperview];
        }];
    }
}

- (void)sizeToFit {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.silverLabel.frame.origin.x+self.silverLabel.frame.size.width, self.frame.size.height);
}


@end
