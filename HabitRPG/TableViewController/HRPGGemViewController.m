//
//  HRPGGemViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGemViewController.h"
#import "HRPGPurchaseLoadingButton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HRPGGemViewController ()
@property (weak, nonatomic) IBOutlet UILabel *notEnoughGemsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gemImageView;
@property (weak, nonatomic) IBOutlet HRPGPurchaseLoadingButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation HRPGGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.purchaseButton.tintColor = [UIColor colorWithRed:0.837 green:0.652 blue:0.238 alpha:1.000];
    self.purchaseButton.text = @"$4.99";
    
    self.purchaseButton.onTouchEvent = ^void(HRPGPurchaseLoadingButton *purchaseButton) {
        switch (purchaseButton.state) {
            case HRPGPurchaseButtonStateLabel:
                purchaseButton.state = HRPGPurchaseButtonStateConfirm;
                break;
                
            case HRPGPurchaseButtonStateConfirm:
                purchaseButton.state = HRPGPurchaseButtonStateLoading;
                break;
            case HRPGPurchaseButtonStateLoading:
                purchaseButton.state = HRPGPurchaseButtonStateDone;
                break;
            case HRPGPurchaseButtonStateDone:
                purchaseButton.state = HRPGPurchaseButtonStateLabel;
                break;
            default:
                break;
        }
    };
    
    [self.gemImageView sd_setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/Pet_Currency_Gem.png"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.displayNoGemLabel) {
        self.notEnoughGemsLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPress:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
    }];
}

@end
