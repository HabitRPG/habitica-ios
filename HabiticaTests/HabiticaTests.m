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
    RKManagedObjectStore *managedObjectStore = [RKTestFactory managedObjectStore];
    NSError *error = nil;
    [managedObjectStore addInMemoryPersistentStore:&error];
    [self.sharedManager loadObjectManager:managedObjectStore];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFetchUser {
    User *user = [self.sharedManager getUser];
    XCTAssertNil(user);
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"habitrpg.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"user.json",nil)
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"userFetched"];
    
    [self.sharedManager fetchUser:^() {
        [expectation fulfill];
    } onError:^() {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        User *user = [self.sharedManager getUser];
        XCTAssert([user.username isEqualToString:@"testuser"]);
    }];
}



@end
