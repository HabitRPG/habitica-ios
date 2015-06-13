//
//  HRPGGemViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGemViewController.h"
#import "HRPGPurchaseLoadingButton.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CargoBay.h>


@interface HRPGGemViewController ()
@property (weak, nonatomic) IBOutlet UILabel *notEnoughGemsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gemImageView;
@property (weak, nonatomic) IBOutlet HRPGPurchaseLoadingButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic) SKProduct *gemProduct;
@end

@implementation HRPGGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.purchaseButton.tintColor = [UIColor colorWithRed:0.837 green:0.652 blue:0.238 alpha:1.000];
    self.purchaseButton.state = HRPGPurchaseButtonStateLoading;
    
    self.purchaseButton.onTouchEvent = ^void(HRPGPurchaseLoadingButton *purchaseButton) {
        switch (purchaseButton.state) {
            case HRPGPurchaseButtonStateError:
            case HRPGPurchaseButtonStateLabel:
                purchaseButton.state = HRPGPurchaseButtonStateLoading;
                [self purchaseGems];
                break;
            case HRPGPurchaseButtonStateDone:
                [self dismissViewControllerAnimated:YES completion:^() {
                    
                }];
            default:
                break;
        }
    };
    self.gemImageView.image = [UIImage imageNamed:@"Gem"];
    
    NSArray *identifiers = @[@"com.habitrpg.ios.Habitica.20gems"];
    
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  if (products.count == 1) {
                                                      self.gemProduct = products[0];
                                                      NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                                      [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                                                      [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                                      [numberFormatter setLocale:self.gemProduct.priceLocale];
                                                      self.purchaseButton.text = [numberFormatter stringFromNumber:self.gemProduct.price];
                                                      self.purchaseButton.state = HRPGPurchaseButtonStateLabel;
                                                  } else {
                                                      self.purchaseButton.state = HRPGPurchaseButtonStateError;
                                                  }
                                                  
                                              } failure:^(NSError *error) {
                                                  NSLog(@"%@", error);
                                                  self.purchaseButton.state = HRPGPurchaseButtonStateError;
                                              }];
    
    
    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        for (SKPaymentTransaction *transaction in transactions) {
            NSLog(@"Transaction: %@, %ld", transaction, (long)transaction.transactionState);
            switch (transaction.transactionState) {
                    // Call the appropriate custom method for the transaction state.
                case SKPaymentTransactionStatePurchasing:
                    self.purchaseButton.state = HRPGPurchaseButtonStateLoading;
                    break;
                case SKPaymentTransactionStateDeferred:
                    self.purchaseButton.state = HRPGPurchaseButtonStateLoading;
                    break;
                case SKPaymentTransactionStateFailed:
                    NSLog(@"%@", transaction.error);
                    self.purchaseButton.state = HRPGPurchaseButtonStateError;
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    break;
                case SKPaymentTransactionStatePurchased:
                    [self verifyTransaction:transaction];
                    break;
                case SKPaymentTransactionStateRestored:
                    self.purchaseButton.state = HRPGPurchaseButtonStateDone;
                    break;
                default:
                    // For debugging
                    NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                    break;
            }
        }
    }];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.displayNoGemLabel) {
        self.notEnoughGemsLabel.text = @"";
    }
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (IBAction)cancelButtonPress:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
    }];
}

- (void)purchaseGems {
    if (self.gemProduct) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:self.gemProduct];
        payment.quantity = 1;
        payment.applicationUsername = [[self.sharedManager getUser] hashedValueForAccountName];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)verifyTransaction:(SKPaymentTransaction*)transaction {
    [[CargoBay sharedManager] verifyTransaction:transaction password:nil success:^(NSDictionary *receipt) {
        
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        NSDictionary *receiptDict = @{@"transaction": @{@"receipt": [receiptData base64EncodedStringWithOptions:0]}};
        [self.sharedManager purchaseGems:receiptDict onSuccess:^() {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            self.purchaseButton.state = HRPGPurchaseButtonStateDone;
        }onError:^() {
            [self handleInvalidReceipt:transaction];
        }];
        
    } failure:^(NSError *error) {
        [self handleInvalidReceipt:transaction];
    }];
}

- (void) handleInvalidReceipt:(SKPaymentTransaction*)transaction {
    self.purchaseButton.state = HRPGPurchaseButtonStateError;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error", nil)
                              message:NSLocalizedString(@"There was an error verifying your purchase", nil)
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    
    [alertView show];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
