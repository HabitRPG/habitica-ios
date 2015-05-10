//
//  HabiticaTests.m
//  HabiticaTests
//
//  Created by viirus on 13.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>
#import <RestKit/Testing.h>
#import "HRPGManager.h"
#import <OHHTTPStubs.h>
#import <PDKeychainBindings.h>
#import "Reward.h"

@interface HabiticaTests : XCTestCase
@property HRPGManager *sharedManager;
@end

@implementation HabiticaTests

- (void)setUp {
    [super setUp];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.habitrpg.ios.Habitica"];    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [keyChain removeObjectForKey:@"id"];
    [keyChain removeObjectForKey:@"key"];
    
    self.sharedManager = [[HRPGManager alloc] init];
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HabitRPG" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error = nil;
    [managedObjectStore addInMemoryPersistentStore:&error];
    [managedObjectStore createManagedObjectContexts];
    [self.sharedManager loadObjectManager:managedObjectStore];
    [self setUpStubs];
}

- (void) setUpStubs {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"habitrpg.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        OHHTTPStubsResponse *response;
        if ([request.URL.path isEqualToString:@"/api/v2/user"]) {
            response = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"user.json",self.class)
                                                        statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        } else if ([request.URL.path isEqualToString:@"/api/v2/user/inventory/equip/costume/armor_special_fallWarrior"]) {
            response = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"blade-equipResponse.json",self.class)
                                                        statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        }
        return response;
    }];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFetchUser {

    XCTestExpectation *expectation = [self expectationWithDescription:@"userFetched"];
    
    [self.sharedManager fetchUser:^() {
        [expectation fulfill];
    } onError:^() {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        User *user = [self.sharedManager getUser];
        XCTAssertEqualObjects(user.username, @"testuser");
    }];
}

- (void)testRewardsWithTags {
    XCTestExpectation *expectation = [self expectationWithDescription:@"rewardsWithTags"];
    
    [self.sharedManager fetchUser:^() {
        [expectation fulfill];
    } onError:^() {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        NSArray *rewards = [[self.sharedManager getUser].rewards allObjects];
        for (Reward *reward in rewards) {
            if ([reward.text isEqualToString:@"Cake"]) {
                XCTAssertEqual(1, reward.tags.count);
            } else {
                XCTAssertEqual(0, reward.tags.count);
            }
        }
    }];
}

- (void)testEquipping {
    XCTestExpectation *expectation = [self expectationWithDescription:@"equipGear"];
    
    [self.sharedManager fetchUser:^() {
        [self.sharedManager equipObject:@"armor_special_fallWarrior" withType:@"costume" onSuccess:^() {
            [expectation fulfill];
        }onError:^() {
            [expectation fulfill];
        }];
    } onError:^() {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssertEqualObjects([self.sharedManager getUser].costumeArmor, @"armor_special_fallWarrior");
    }];
}


@end
