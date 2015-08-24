//
//  HabiticaTests.m
//  HabiticaTests
//
//  Created by viirus on 13.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HabiticaTests.h"
#import <RestKit/RestKit.h>
#import <RestKit/Testing.h>
#import "HRPGManager.h"
#import <OHHTTPStubs.h>
#import <PDKeychainBindings.h>


@implementation HabiticaTests

- (void) setUpStubs {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"habitica.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        OHHTTPStubsResponse *response;
        if ([request.URL.path isEqualToString:@"/api/v2/user"]) {
            response = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"user.json",self.class)
                                                        statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        } else if ([request.URL.path isEqualToString:@"/api/v2/user/inventory/equip/costume/armor_special_fallWarrior"]) {
            response = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"blade-equipResponse.json",self.class)
                                                        statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        } else if ([request.URL.path isEqualToString:@"/api/v2/content"]) {
            response = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"content-24.8.15.json",self.class)
                                                        statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        }
        return response;
    }];
}

- (void)initializeCoreDataStorage {
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
}


- (void)tearDown {
    [super tearDown];
}



@end
