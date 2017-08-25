//
//  HRPGShopViewModel.h
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Shop;

@interface HRPGShopViewModel : NSObject

@property Shop *shop;

- (NSFetchedResultsController *)fetchedShopItemResultsForIdentifier:(NSString *)identifier;
- (void)fetchShopInformationForIdentifier:(NSString *)identifier;
- (BOOL)shouldPromptToSubscribe;
@end
