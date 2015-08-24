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

- (void)testThatItHasEquipmentForMages {
    self.sharedManager.user.hclass = @"wizard";
    [self presentView];
    XCTAssertEqual(self.viewController.filteredData.count, 1);
    XCTAssertEqual(((NSArray*)self.viewController.filteredData[0]).count, 5);
    XCTAssertEqualObjects([self.viewController.filteredData[0][0] key], @"potion");
    int x = 1;
    for (NSString *type in gearTypes) {
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] type], type);
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] getCleanedClassName], @"mage");
        x++;
    }
}

- (void)testThatItHasEquipmentForRogues {
    self.sharedManager.user.hclass = @"rogue";
    [self presentView];
    XCTAssertEqual(self.viewController.filteredData.count, 1);
    XCTAssertEqual(((NSArray*)self.viewController.filteredData[0]).count, 5);
    XCTAssertEqualObjects([self.viewController.filteredData[0][0] key], @"potion");
    int x = 1;
    for (NSString *type in gearTypes) {
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] type], type);
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] getCleanedClassName], @"rogue");
        x++;
    }
}

- (void)testThatItHasEquipmentForWarriors {
    self.sharedManager.user.hclass = @"warrior";
    [self presentView];
    XCTAssertEqual(self.viewController.filteredData.count, 1);
    XCTAssertEqual(((NSArray*)self.viewController.filteredData[0]).count, 5);
    XCTAssertEqualObjects([self.viewController.filteredData[0][0] key], @"potion");
    int x = 1;
    for (NSString *type in gearTypes) {
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] type], type);
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] getCleanedClassName], @"warrior");
        x++;
    }
}

- (void)testThatItHasEquipmentForHealers {
    self.sharedManager.user.hclass = @"healer";
    [self presentView];
    XCTAssertEqual(self.viewController.filteredData.count, 1);
    XCTAssertEqual(((NSArray*)self.viewController.filteredData[0]).count, 5);
    XCTAssertEqualObjects([self.viewController.filteredData[0][0] key], @"potion");
    int x = 1;
    for (NSString *type in gearTypes) {
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] type], type);
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] getCleanedClassName], @"healer");
        x++;
    }
}

- (void)testThatItHasEquipmentForNoClass {
    [self presentView];
    XCTAssertEqual(self.viewController.filteredData.count, 1);
    XCTAssertEqual(((NSArray*)self.viewController.filteredData[0]).count, 5);
    XCTAssertEqualObjects([self.viewController.filteredData[0][0] key], @"potion");
    int x = 1;
    for (NSString *type in gearTypes) {
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] type], type);
        XCTAssertEqualObjects([(Gear*)self.viewController.filteredData[0][x] getCleanedClassName], @"warrior");
        x++;
    }
}

@end
