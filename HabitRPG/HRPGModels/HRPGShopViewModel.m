//
//  HRPGShopViewModel.m
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGShopViewModel.h"
#import "Shop.h"
#import "User.h"
#import "HRPGManager.h"
#import "Habitica-Swift.h"
@implementation HRPGShopViewModel

- (void) fetchShopInformationForIdentifier:(NSString *)identifier {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shop"
                                              inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]];
    
    NSError *error;
    NSArray *results = [[[HRPGManager sharedManager] getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (results.count > 0) {
        self.shop = results[0];
    }
}

- (NSFetchedResultsController *)fetchedShopItemResultsForIdentifier:(NSString *)identifier {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopItem"
                                              inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSString *predicateString = @"category.shop.identifier == %@";
    if ([[HRPGManager sharedManager] getUser].subscriptionPlan.isActive) {
        predicateString = [predicateString stringByAppendingString:@" && (isSubscriberItem == nil || isSubscriberItem != YES)"];
    }
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateString, identifier]];
    
    NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSSortDescriptor *categoryIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category.text" ascending:YES];
    NSArray *sortDescriptors = @[ categoryIndexDescriptor, indexDescriptor ];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]
                                          sectionNameKeyPath:@"category.text"
                                                   cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (BOOL)shouldPromptToSubscribe {
    BOOL isTimeTrav = [self.shop.identifier isEqualToString:TimeTravelersShopKey];
    return isTimeTrav && ![[HRPGManager sharedManager] getUser].subscriptionPlan;
}

- (NSDictionary *)fetchOwnedItems {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BuyableItem"
                                              inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"owned > 0"]];
    
    NSError *error;
    NSArray *results = [[[HRPGManager sharedManager] getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *ownedItems = [[NSMutableDictionary alloc] initWithCapacity:results.count];
    for (Item *item in results) {
        [ownedItems setValue:item forKey:item.key];
    }
    return ownedItems;
}

@end
