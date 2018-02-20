//
//  HabiticaTests.m
//  HabiticaTests
//
//  Created by Elliot Schrock on 1/26/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HabiticaTests.h"
#import <RestKit/RestKit.h>
#import "HRPGManager.h"
#import "OHHTTPStubs.h"


@implementation HabiticaTests

- (void) setUpStubs {
}

- (void)setUp {
    [super setUp];
}

- (void)initializeCoreDataStorage {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.habitrpg.ios.Habitica"];
    
    self.sharedManager = [[HRPGManager alloc] init];
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Habitica" ofType:@"momd"]];
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
