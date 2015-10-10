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
#import "UIColor+Habitica.h"

@interface HRPGGemView ()

@property UIImageView *gemImageView;
@property HRPGAbbrevNumberLabel *gemLabel;
@property NSNumber *gems;

@end

@implementation HRPGGemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.gemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 18, 13)];
        self.gemImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.gemImageView setImage:[UIImage imageNamed:@"Gem"]];
        self.gemLabel = [[HRPGAbbrevNumberLabel alloc] initWithFrame:CGRectMake(21, 0, 100, 15)];
        self.gemLabel.text = [NSString stringWithFormat:@"%ld", (long) [self.gems integerValue]];
        self.gemLabel.font = [UIFont systemFontOfSize:13.0];
        self.gemLabel.textColor = [UIColor purple300];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

@end
