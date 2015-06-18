//
//  HRPGGemView.m
//  Habitica
//
//  Created by viirus on 21.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGemView.h"
#import "HRPGAbbrevNumberLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HRPGGemView ()

@property UIImageView *gemImageView;
@property HRPGAbbrevNumberLabel *gemLabel;
@property NSNumber *gems;

@end

@implementation HRPGGemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.gemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, self.frame.size.height)];
        self.gemImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.gemImageView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/Pet_Currency_Gem.png"]];
        self.gemLabel = [[HRPGAbbrevNumberLabel alloc] initWithFrame:CGRectMake(26, 0, 100, self.frame.size.height)];
        self.gemLabel.text = [NSString stringWithFormat:@"%ld", (long) [self.gems integerValue]];
        [self.gemLabel sizeToFit];
        
        [self addSubview:self.gemLabel];
        [self addSubview:self.gemImageView];
        
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGemPurchaseView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    
    return self;
}

- (void)updateViewWithGemcount:(NSNumber *)gemCount withDiffString:(NSString *)amount {
    self.gems = gemCount;
    self.gemLabel.text = [NSString stringWithFormat:@"%ld", (long) [gemCount integerValue]];
    [self.gemLabel sizeToFit];
}

- (void)sizeToFit {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.gemLabel.frame.origin.x+self.gemLabel.frame.size.width, self.frame.size.height);
}

- (void)openGemPurchaseView:(UITapGestureRecognizer *)tapGestureRecognizer {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

@end
