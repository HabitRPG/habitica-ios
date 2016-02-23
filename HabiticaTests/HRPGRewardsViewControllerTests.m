//
//  HRPGEquipmentViewControllerTests.m
//  Habitica
//
//  Created by Phillip Thelen on 24/08/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HabiticaTests.h"
#import "HRPGRewardsViewController.h"
#import <RestKit/RestKit.h>
#import <OHHTTPStubs.h>
#import "Gear.h"

@interface HRPGRewardsViewControllerTests : HabiticaTests

@property HRPGRewardsViewController *viewController;

@end

@implementation HRPGRewardsViewControllerTests

NSArray *gearTypes;

- (void)setUp {
    [super setUp];
    
    gearTypes = @[@"armor",@"headgear", @"shield", @"weapon"];
    
    self.viewController = [[HRPGRewardsViewController alloc] initWithCoder:nil];
    [self initializeCoreDataStorage];
    self.sharedManager.user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[self.sharedManager getManagedObjectContext]];
    self.viewController.sharedManager = self.sharedManager;
    [self loadTestData];
}

- (void) presentView {
    [self.viewController viewDidLoad];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidAppear:YES];
}


- (void) loadTestData {
    NSManagedObjectContext *moc = [self.sharedManager getManagedObjectContext];
    Gear *potion = [NSEntityDescription insertNewObjectForEntityForName:@"Potion" inManagedObjectContext:[self.sharedManager getManagedObjectContext]];
    potion.type = @"potion";
    potion.key = @"potion";
    for (NSString *klass in @[@"mage", @"rogue", @"healer", @"warrior"]) {
        for (NSString *type in gearTypes) {
            for (NSNumber *index in @[@1, @2, @3, @4]) {
                Gear *gear = [NSEntityDescription insertNewObjectForEntityForName:@"Gear" inManagedObjectContext:[self.sharedManager getManagedObjectContext]];
                gear.klass = klass;
                gear.type = type;
                gear.index = index;
                gear.key = [NSString stringWithFormat:@"%@_%@_%@", klass, type, index];
                NSError *error;
                [moc saveToPersistentStore:&error];
            }
        }
    }
}

- (void)tearDown {
    [super tearDown];
}

@end
