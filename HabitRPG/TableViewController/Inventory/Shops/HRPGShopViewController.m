//
//  HRPGShopViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGShopViewController.h"
#import "HRPGCoreDataDataSource.h"
#import "ShopItem.h"
#import "Shop.h"
#import "HRPGRewardTableViewCell.h"
#import "User.h"
#import "HRPGGearDetailView.h"
#import "KLCPopup.h"
#import "NSString+StripHTML.h"

@interface HRPGShopViewController ()

@property HRPGCoreDataDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopDescription;

@property User *user;

@property Shop *shop;
@property NSIndexPath *selectedIndex;

@end

@implementation HRPGShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [self.sharedManager getUser];
    
    [self fetchShopInformation];
    [self refresh];
    [self setupTableView];
}

- (void)refresh {
    __weak HRPGShopViewController *weakSelf = self;
    [self.sharedManager fetchShopInventory:self.shopIdentifier onSuccess:^() {
        [weakSelf fetchShopInformation];
    }onError:nil];
}

- (void)setupTableView {
    __weak HRPGShopViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(HRPGRewardTableViewCell *cell, ShopItem *shopItem, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withShopItem:shopItem atIndexPath:indexPath];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"category.shop.identifier == %@", weakSelf.shopIdentifier];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *indexDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSSortDescriptor *categoryIndexDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"category.index" ascending:YES];
        NSArray *sortDescriptors = @[ categoryIndexDescriptor, indexDescriptor ];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"ShopItem"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
    self.dataSource.sectionNameKeyPath = @"category.index";
}

- (void) fetchShopInformation {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shop"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", self.shopIdentifier]];
    
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results.count > 0) {
        self.shop = results[0];
        [self updateShopInformationViews];
    }
}

- (void) updateShopInformationViews {
    [self.sharedManager setImage:self.shop.imageName withFormat:@"png" onView:self.headerImageView];
    self.navigationItem.title = self.shop.text;
    self.shopDescription.text = [self.shop.notes stringByStrippingHTML];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 60.0f;
    float width = self.viewWidth - 127;
    ShopItem *shopItem = [self.dataSource itemAtIndexPath:indexPath];
    width = width -
    [[NSString stringWithFormat:@"%ld", (long)[shopItem.value integerValue]]
     boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
     options:NSStringDrawingUsesLineFragmentOrigin
     attributes:@{
                  NSFontAttributeName :
                      [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                  }
     context:nil]
    .size.width;
    height = height +
    [shopItem.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{
                                        NSFontAttributeName : [UIFont
                                                               preferredFontForTextStyle:UIFontTextStyleHeadline]
                                        }
                              context:nil]
    .size.height;
    if ([shopItem.notes length] > 0) {
        NSInteger notesHeight =
        [shopItem.notes
         boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{
                      NSFontAttributeName :
                          [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                      }
         context:nil]
        .size.height;
        
        if (notesHeight <
            [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].lineHeight * 5) {
            height = height + notesHeight;
        } else {
            height =
            height + [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].lineHeight * 5;
        }
    }
    if (height < 87) {
        return 87;
    }
    return height;
}

- (void) configureCell:(HRPGRewardTableViewCell *)cell withShopItem:(ShopItem *)shopItem atIndexPath:(NSIndexPath *)indexPath {
    
    if (shopItem.imageName) {
        [self.sharedManager setImage:shopItem.imageName withFormat:@"png" onView:cell.shopImageView];
    }
    NSNumber *ownedCurrency;
    if ([shopItem.currency isEqualToString:@"gems"]) {
        ownedCurrency = [NSNumber numberWithFloat:(4*[self.user.balance floatValue])];
    } else {
        ownedCurrency = self.user.gold;
    }
    [cell configureForShopItem:shopItem withCurrencyOwned:ownedCurrency];
    
    __weak HRPGShopViewController *weakSelf = self;
    [cell onPurchaseTap:^() {
        weakSelf.selectedIndex = indexPath;
        UIAlertView *confirmationAlert = [[UIAlertView alloc]
                                          initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Buy %@ for %@ %@", nil), shopItem.text, shopItem.value, shopItem.currency]
                                          message:nil
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Buy", nil), nil];
        [confirmationAlert show];
    }];}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShopItem *item = [self.dataSource itemAtIndexPath:indexPath];
    
    NSArray *nibViews =
    [[NSBundle mainBundle] loadNibNamed:@"HRPGGearDetailView" owner:self options:nil];
    HRPGGearDetailView *gearView = nibViews[0];
    CGFloat ownedCurrency;
    if ([item.currency isEqualToString:@"gems"]) {
        ownedCurrency = (4*[self.user.balance floatValue]);
    } else if ([item.currency isEqualToString:@"hourglasses"]) {
        ownedCurrency = [self.user.hourglasses floatValue];
    } else {
        ownedCurrency = [self.user.gold floatValue];
    }
    [gearView configureForShopItem:item withCurrencyAmount:ownedCurrency];
    __weak HRPGShopViewController *weakSelf = self;
    gearView.buyAction = ^() {
        [weakSelf buyItem:item];
    };
    [self.sharedManager setImage:item.imageName withFormat:@"png" onView:gearView.imageView];
    [gearView sizeToFit];
    
    KLCPopup *popup = [KLCPopup popupWithContentView:gearView
                                            showType:KLCPopupShowTypeBounceIn
                                         dismissType:KLCPopupDismissTypeBounceOut
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:YES
                               dismissOnContentTouch:NO];
    [popup show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
    if (buttonIndex == 1) {
        [self buyItem:[self.dataSource itemAtIndexPath:self.selectedIndex]];
    }
}

- (void)buyItem:(ShopItem *)item {
    __weak HRPGShopViewController *weakSelf = self;
    if (![self.shopIdentifier isEqualToString:TimeTravelersShopKey]) {
        [self.sharedManager purchaseItem:item.key fromType:item.purchaseType onSuccess:^() {
            [weakSelf refresh];
        } onError:nil];
    } else {
        if ([item.purchaseType isEqualToString:@"gear"]) {
            [self.sharedManager purchaseMysterySet:item.category.identifier onSuccess:^() {
                [weakSelf refresh];
            } onError:nil];
        } else {
            [self.sharedManager purchaseHourglassItem:item.key fromType:item.purchaseType onSuccess:^() {
                [weakSelf refresh];
            } onError:nil];
        }
    }
}

@end
