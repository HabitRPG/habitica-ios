//
//  HRPGAPITests.m
//  Habitica
//
//  Created by Phillip Thelen on 21/08/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HabiticaTests.h"
#import "HRPGManager.h"
#import "Reward.h"

@interface HRPGAPITests : HabiticaTests

@end

@implementation HRPGAPITests

- (void)setUp {
    [super setUp];
    [self initializeCoreDataStorage];
    [self setUpStubs];
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
        XCTAssertEqualObjects([self.sharedManager getUser].costume.armor, @"armor_special_fallWarrior");
    }];
}
@end
