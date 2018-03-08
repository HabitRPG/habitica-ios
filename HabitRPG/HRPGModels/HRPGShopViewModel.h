//
//  HRPGShopViewModel.h
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "InAppReward+CoreDataClass.h"
@class Shop;

@interface HRPGShopViewModel : NSObject

@property Shop *shop;

- (NSFetchedResultsController *)fetchedShopItemResultsForIdentifier:(NSString *)identifier withGearCategory:(NSString *)gearCategory;
- (void)fetchShopInformationForIdentifier:(NSString *)identifier;
- (BOOL)shouldPromptToSubscribe;

- (NSDictionary<NSString *, Item *> *)fetchOwnedItems;
- (NSDictionary<NSString *, InAppReward *> *)fetchPinnedItems;
@end
