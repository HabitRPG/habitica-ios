//
//  HRPGGemViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGemViewController.h"
#import <CargoBay.h>
#import "HRPGAppDelegate.h"
#import "HRPGPurchaseLoadingButton.h"
#import "MRProgress.h"
#import "UIColor+Habitica.h"

@interface HRPGGemViewController ()
@property(weak, nonatomic) IBOutlet UILabel *notEnoughGemsLabel;
@property(weak, nonatomic) IBOutlet UIImageView *gemImageView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic) NSMutableDictionary *products;
@property(nonatomic) NSArray *identifiers;
@property(nonatomic) UIView *headerView;
@property MRProgressOverlayView *overlayView;
@end

@implementation HRPGGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gemImageView.image = [UIImage imageNamed:@"Gem"];

    self.identifiers = @[
        @"com.habitrpg.ios.Habitica.4gems", @"com.habitrpg.ios.Habitica.21gems",
        @"com.habitrpg.ios.Habitica.42gems"
    ];
    self.products = [NSMutableDictionary dictionaryWithCapacity:self.identifiers.count];

    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:self.identifiers]
        success:^(NSArray *products, NSArray *invalidIdentifiers) {
            for (SKProduct *product in products) {
                self.products[product.productIdentifier] = product;
            }
            [self.tableView reloadData];
            [self.overlayView dismiss:YES];
        }
        failure:^(NSError *error) {
            [self.overlayView dismiss:YES];
            NSLog(@"%@", error);
        }];

    [[CargoBay sharedManager]
        setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
            for (SKPaymentTransaction *transaction in transactions) {
                HRPGPurchaseLoadingButton *purchaseButton;
                NSInteger count = 0;
                for (NSString *identifier in self.identifiers) {
                    if ([identifier isEqualToString:transaction.payment.productIdentifier]) {
                        break;
                    }
                    count++;
                }
                UITableViewCell *cell = [self.tableView
                    cellForRowAtIndexPath:[NSIndexPath indexPathForItem:count inSection:0]];
                purchaseButton = [cell viewWithTag:2];
                switch (transaction.transactionState) {
                    // Call the appropriate custom method for the transaction state.
                    case SKPaymentTransactionStatePurchasing:
                        purchaseButton.state = HRPGPurchaseButtonStateLoading;
                        break;
                    case SKPaymentTransactionStateDeferred:
                        purchaseButton.state = HRPGPurchaseButtonStateLoading;
                        break;
                    case SKPaymentTransactionStateFailed:
                        NSLog(@"%@", transaction.error);
                        purchaseButton.state = HRPGPurchaseButtonStateError;
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        self.navigationItem.leftBarButtonItem.enabled = YES;
                        break;
                    case SKPaymentTransactionStatePurchased:
                        [self verifyTransaction:transaction withButton:purchaseButton];
                        break;
                    case SKPaymentTransactionStateRestored:
                        purchaseButton.state = HRPGPurchaseButtonStateDone;
                        break;
                    default:
                        // For debugging
                        NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                        break;
                }
            }
        }];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];

    self.headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    UILabel *titleLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width - 16,
                                                  self.headerView.frame.size.height)];
    titleLabel.text =
        NSLocalizedString(@"Gems are purchased with real money, which makes it possible for "
                          @"Habitica to release new updates. Gems can be used to buy special "
                          @"items and backgrounds. Thank you for supporting us!",
                          nil);
    titleLabel.numberOfLines = 0;
    [self.headerView addSubview:titleLabel];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.overlayView =
        [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKProduct *product = self.products[self.identifiers[indexPath.item]];
    UITableViewCell *cell =
        [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    UILabel *titleLabel = [cell viewWithTag:1];
    HRPGPurchaseLoadingButton *purchaseButton = [cell viewWithTag:2];

    titleLabel.text = product.localizedTitle;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    purchaseButton.text = [numberFormatter stringFromNumber:product.price];
    purchaseButton.state = HRPGPurchaseButtonStateLabel;
    purchaseButton.tintColor = [UIColor purple400];
    purchaseButton.onTouchEvent = ^void(HRPGPurchaseLoadingButton *purchaseButton) {
        switch (purchaseButton.state) {
            case HRPGPurchaseButtonStateError:
            case HRPGPurchaseButtonStateLabel:
                purchaseButton.state = HRPGPurchaseButtonStateLoading;
                [self purchaseGems:product withButton:purchaseButton];
                break;
            case HRPGPurchaseButtonStateDone:
                [self dismissViewControllerAnimated:YES
                                         completion:^(){

                                         }];
            default:
                break;
        }
    };

    return cell;
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate =
            (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (IBAction)cancelButtonPress:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^(){

                                                  }];
}

- (void)purchaseGems:(SKProduct *)product withButton:(HRPGPurchaseLoadingButton *)purchaseButton {
    if (product) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = 1;
        payment.applicationUsername = [[self.sharedManager getUser] hashedValueForAccountName];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        purchaseButton.state = HRPGPurchaseButtonStateError;
    }
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
               withButton:(HRPGPurchaseLoadingButton *)purchaseButton {
    [[CargoBay sharedManager] verifyTransaction:transaction
        password:nil
        success:^(NSDictionary *receipt) {

            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSDictionary *receiptDict = @{
                @"transaction" : @{@"receipt" : [receiptData base64EncodedStringWithOptions:0]}
            };
            [self.sharedManager purchaseGems:receiptDict
                onSuccess:^() {
                    SKPaymentQueue *currentQueue = [SKPaymentQueue defaultQueue];
                    [currentQueue.transactions
                        enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
                        }];
                    purchaseButton.state = HRPGPurchaseButtonStateDone;
                }
                onError:^() {
                    [self handleInvalidReceipt:transaction withButton:purchaseButton];
                }];

        }
        failure:^(NSError *error) {
            [self handleInvalidReceipt:transaction withButton:purchaseButton];
        }];
}

- (void)handleInvalidReceipt:(SKPaymentTransaction *)transaction
                  withButton:(HRPGPurchaseLoadingButton *)purchaseButton {
    purchaseButton.state = HRPGPurchaseButtonStateError;
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
