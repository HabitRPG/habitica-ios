//
//  HRPGGemView.m
//  Habitica
//
//  Created by viirus on 21.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGemView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation HRPGGemView

UIImageView *gemImageView;
UILabel *gemLabel;
NSNumber *gems;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        gemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, self.frame.size.height)];
        gemImageView.contentMode = UIViewContentModeScaleAspectFit;
        [gemImageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/Pet_Currency_Gem.png"]];
        gemLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 100, self.frame.size.height)];
        gemLabel.text = [NSString stringWithFormat:@"%ld", (long) [gems integerValue]];
        [gemLabel sizeToFit];
        
        [self addSubview:gemLabel];
        [self addSubview:gemImageView];
    }
    
    return self;
}

- (void)updateViewWithGemcount:(NSNumber *)gemCount withDiffString:(NSString *)amount {
    gems = gemCount;
    gemLabel.text = [NSString stringWithFormat:@"%ld", (long) [gemCount integerValue]];
    [gemLabel sizeToFit];
}

@end
