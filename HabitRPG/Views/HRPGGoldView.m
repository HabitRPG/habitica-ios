//
//  HRPGGoldView.m
//  Habitica
//
//  Created by viirus on 15.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGoldView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation HRPGGoldView

UIImageView *goldImageView;
UILabel *goldLabel;
UIImageView *silverImageView;
UILabel *silverLabel;
UIView *moneyView;
NSNumber *gold;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        goldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 22)];
        goldImageView.contentMode = UIViewContentModeScaleAspectFit;
        [goldImageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_gold.png"]];
        goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 100, 20)];
        goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [gold integerValue]];
        [goldLabel sizeToFit];
        
        
        silverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 + goldLabel.frame.size.width, 0, 25, 22)];
        silverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [silverImageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_silver.png"]];
        silverLabel = [[UILabel alloc] initWithFrame:CGRectMake(30 + goldLabel.frame.size.width + 26, 0, 100, 20)];
        int silver = ([gold floatValue] - [gold integerValue]) * 100;
        silverLabel.text = [NSString stringWithFormat:@"%d", silver];
        [silverLabel sizeToFit];
        
        [self addSubview:goldLabel];
        [self addSubview:goldImageView];
        [self addSubview:silverImageView];
        [self addSubview:silverLabel];
    }
    
    return self;
}

- (void)updateRewardView:(NSNumber *)newGold withDiffString:(NSString *)amount {
    NSNumber *gold = newGold;
    goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [gold integerValue]];
    [goldLabel sizeToFit];
    
    int silver = ([gold floatValue] - [gold integerValue]) * 100;
    silverLabel.text = [NSString stringWithFormat:@"%d", silver];
    silverLabel.frame = CGRectMake(30 + goldLabel.frame.size.width + 26, 0, 100, 16);
    
    [silverLabel sizeToFit];
    silverImageView.frame = CGRectMake(30 + goldLabel.frame.size.width, 0, 25, 22);

    if (amount) {
        //animate the gold change
        UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, goldLabel.frame.origin.y, goldLabel.frame.size.width + goldLabel.frame.origin.x, 16)];
        updateLabel.font = [UIFont systemFontOfSize:13.0f];
        updateLabel.textAlignment = NSTextAlignmentRight;
        updateLabel.text = amount;
        updateLabel.textColor = [UIColor redColor];
        [moneyView addSubview:updateLabel];
        [UIView animateWithDuration:0.3 animations:^() {
            updateLabel.frame = CGRectMake(0, 25, goldLabel.frame.size.width + goldLabel.frame.origin.x, 16);
            updateLabel.alpha = 0.0f;
        }                completion:^(BOOL completition) {
            [updateLabel removeFromSuperview];
        }];
    }
}

@end
