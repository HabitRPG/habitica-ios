//
//  HRPGShopViewModel.m
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "HRPGShopViewModel.h"
#import "Shop.h"
#import "User.h"
#import "HRPGManager.h"

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
    
    NSPredicate *predicate;
    if ([[HRPGManager sharedManager] getUser].subscriptionPlan.isActive) {
        predicate = [NSPredicate predicateWithFormat:@"category.shop.identifier == %@", identifier];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"category.shop.identifier == %@ && (isSubscriberItem == nil || isSubscriberItem != YES)", identifier];
    }
    [fetchRequest setPredicate:predicate];
    
//    NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *categoryIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category.text" ascending:YES];
    NSArray *sortDescriptors = @[ categoryIndexDescriptor/*, indexDescriptor*/ ];
    
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

@end
