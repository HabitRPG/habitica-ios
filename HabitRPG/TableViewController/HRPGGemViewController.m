//
//  HRPGGemViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGemViewController.h"
#import "CargoBay.h"
#import "HRPGPurchaseLoadingButton.h"
#import "MRProgress.h"
#import "UIColor+Habitica.h"
#import "HRPGGemPurchaseView.h"
#import "HRPGGemHeaderNavigationController.h"
#import "Seeds.h"
#import <Keys/HabiticaKeys.h>
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h";

@interface HRPGGemViewController ()
@property(weak, nonatomic) IBOutlet UILabel *notEnoughGemsLabel;
@property(weak, nonatomic) IBOutlet UIImageView *gemImageView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic) NSMutableDictionary *products;
@property(nonatomic) NSArray *identifiers;
@property(nonatomic) UIView *headerView;
@property MRProgressOverlayView *overlayView;
@property NSString *seedsGemsInterstitialKey;
@property NSString *seedsShareInterstitialKey;
@end

@implementation HRPGGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HabiticaKeys *keys = [[HabiticaKeys alloc] init];

    UINib *nib = [UINib nibWithNibName:@"GemPurchaseView" bundle:nil];
    [[self collectionView] registerNib:nib forCellWithReuseIdentifier:@"Cell"];
    
    self.gemImageView.image = [UIImage imageNamed:@"Gem"];

    [self.collectionView
     setContentInset:UIEdgeInsetsMake([[self hrpgTopHeaderNavigationController] getContentInset], 0, 0, 0)];
    self.collectionView.scrollIndicatorInsets =
    UIEdgeInsetsMake([[self hrpgTopHeaderNavigationController] getContentInset], 0, 0, 0);
    if ([self hrpgTopHeaderNavigationController].state == HRPGTopHeaderStateHidden) {
        [self.collectionView
         setContentOffset:CGPointMake(0, -[[self hrpgTopHeaderNavigationController] getContentOffset])];
    }
    
    self.identifiers = @[
        @"com.habitrpg.ios.Habitica.4gems", @"com.habitrpg.ios.Habitica.21gems",
        @"com.habitrpg.ios.Habitica.42gems", @"com.habitrpg.ios.Habitica.84gems"
    ];
    self.products = [NSMutableDictionary dictionaryWithCapacity:self.identifiers.count];

    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:self.identifiers]
        success:^(NSArray *products, NSArray *invalidIdentifiers) {
            for (SKProduct *product in products) {
                self.products[product.productIdentifier] = product;
            }
            [self.collectionView reloadData];
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
                if (![self.identifiers containsObject:transaction.payment.productIdentifier]) {
                    return;
                }
                for (NSString *identifier in self.identifiers) {
                    if ([identifier isEqualToString:transaction.payment.productIdentifier]) {
                        break;
                    }
                    count++;
                }
                HRPGGemPurchaseView *cell = (HRPGGemPurchaseView *) [self.collectionView
                    cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count inSection:0]];
                purchaseButton = cell.purchaseButton;
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
    
#ifdef DEBUG
    [[Seeds sharedInstance] start:keys.seedsDevApiKey withHost:@"https://dash.playseeds.com"];
    self.seedsGemsInterstitialKey = keys.seedsDevGemsInterstitial;
    self.seedsShareInterstitialKey = keys.seedsDevShareInterstitial;
#else
    [[Seeds sharedInstance] start:keys.seedsReleaseApiKey withHost:@"https://dash.playseeds.com"];
    self.seedsGemsInterstitialKey = keys.seedsReleaseGemsInterstitial;
    self.seedsShareInterstitialKey = keys.seedsReleaseShareInterstitial;
#endif
    [Seeds.sharedInstance requestInAppMessage:self.seedsGemsInterstitialKey];
    [Seeds.sharedInstance requestInAppMessage:self.seedsShareInterstitialKey];
    Seeds.sharedInstance.inAppMessageDelegate = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewWasTapped:)];
    [self.collectionView addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    HRPGGemHeaderNavigationController *navigationController =
    (HRPGGemHeaderNavigationController *)self.navigationController;
    [navigationController startFollowingScrollView:self.collectionView];
    if (navigationController.state == HRPGTopHeaderStateVisible &&
        self.collectionView.contentOffset.y > -[navigationController getContentOffset]) {
        [navigationController scrollview:self.collectionView
                      scrolledToPosition:self.collectionView.contentOffset.y];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
    
    HRPGGemHeaderNavigationController *navigationController =
    (HRPGGemHeaderNavigationController *)self.navigationController;
    [navigationController stopFollowingScrollView];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.overlayView =
        [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    [self.overlayView setTintColor:[UIColor purple400]];
    [self.overlayView setBackgroundColor:[[UIColor purple50] colorWithAlphaComponent:0.6]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    HRPGGemHeaderNavigationController *navigationController =
    (HRPGGemHeaderNavigationController *)self.navigationController;
    [navigationController scrollview:scrollView scrolledToPosition:scrollView.contentOffset.y];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.products.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKProduct *product = self.products[self.identifiers[indexPath.item]];
    CGFloat height = 200.0;
    if ([product.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.84gems"]) {
        height = height + 28;
    }
    return CGSizeMake((self.view.frame.size.width/2)-36, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak HRPGGemViewController *weakSelf = self;

    SKProduct *product = self.products[self.identifiers[indexPath.item]];
    HRPGGemPurchaseView *cell =
    [self.collectionView  dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    [cell setPrice:[numberFormatter stringFromNumber:product.price]];
    
    [cell showSeedsPromo:NO];
    
    if ([product.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.4gems"]) {
        [cell setGemAmount:4];
    } else if ([product.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.21gems"]) {
        [cell setGemAmount:21];
    } else if ([product.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.42gems"]) {
        [cell setGemAmount:42];
    } else if ([product.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.84gems"]) {
        [cell setGemAmount:84];
        [cell showSeedsPromo:YES];
    }
    
    [cell setPurchaseTap:^void(HRPGPurchaseLoadingButton *purchaseButton) {
        switch (purchaseButton.state) {
            case HRPGPurchaseButtonStateError:
            case HRPGPurchaseButtonStateLabel:
                purchaseButton.state = HRPGPurchaseButtonStateLoading;
                [weakSelf purchaseGems:product withButton:purchaseButton];
                break;
            case HRPGPurchaseButtonStateDone:
                [weakSelf dismissViewControllerAnimated:YES
                                         completion:^(){
                                             
                                         }];
            default:
                break;
        }
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        identifier = @"HeaderView";
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        identifier = @"FooterView";
    }
    
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (kind == UICollectionElementKindSectionHeader) {
        UIImageView *imageView = (UIImageView *) [view viewWithTag:1];
        imageView.image = HabiticaIcons.imageOfHeartLarge;
    }
    
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SKProduct *product = self.products[self.identifiers[indexPath.item]];
    HRPGGemPurchaseView *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    cell.purchaseButton.state = HRPGPurchaseButtonStateLoading;
    [self purchaseGems:product withButton:cell.purchaseButton];
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
        payment.applicationUsername = [[[HRPGManager sharedManager] getUser] hashedValueForAccountName];
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
            [[HRPGManager sharedManager] purchaseGems:receiptDict
                onSuccess:^() {
                    SKPaymentQueue *currentQueue = [SKPaymentQueue defaultQueue];
                    [currentQueue.transactions
                        enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
                        }];
                    purchaseButton.state = HRPGPurchaseButtonStateDone;
                    if ([transaction.payment.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.4gems"]) {
                        [[Seeds sharedInstance] recordIAPEvent:transaction.payment.productIdentifier price:0.99];
                    } else if ([transaction.payment.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.21gems"]) {
                        [[Seeds sharedInstance] recordIAPEvent:transaction.payment.productIdentifier price:4.99];
                    } else if ([transaction.payment.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.42gems"]) {
                        [[Seeds sharedInstance] recordIAPEvent:transaction.payment.productIdentifier price:9.99];
                    } else if ([transaction.payment.productIdentifier isEqualToString:@"com.habitrpg.ios.Habitica.84gems"]) {
                        [[Seeds sharedInstance] recordSeedsIAPEvent:transaction.payment.productIdentifier price:19.99];
                        [self showInterstitial:self.seedsShareInterstitialKey withContext:@"store"];
                    }
                    
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

- (void)seedsInAppMessageClicked:(NSString*)messageId {
    SKProduct *gemsProduct = self.products[@"com.habitrpg.ios.Habitica.84gems"];
    [self purchaseGems:gemsProduct withButton:nil];
}

- (void)seedsInAppMessageDismissed:(NSString *)messageId {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)showInterstitial: (NSString*)messageId withContext:(NSString*)context {
    if ([Seeds.sharedInstance isInAppMessageLoaded:messageId])
        [Seeds.sharedInstance showInAppMessage:messageId in:self withContext: context];
    else
        // Skip the interstitial showing this time and try to reload the interstitial
        [Seeds.sharedInstance requestInAppMessage:messageId];
}

- (void)collectionViewWasTapped:(UITapGestureRecognizer *)tap {
    CGPoint tapLocation = [tap locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath) {
        HRPGGemPurchaseView *cell = (HRPGGemPurchaseView *)[self.collectionView cellForItemAtIndexPath:indexPath];
        CGRect mySubviewRectInCollectionViewCoorSys = [self.collectionView convertRect:cell.seeds_promo.frame fromView:cell];
        if (CGRectContainsPoint(mySubviewRectInCollectionViewCoorSys, tapLocation)) {
            [self showInterstitial:self.seedsGemsInterstitialKey withContext:@"store"];
        }
    }
}

@end
