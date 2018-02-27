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
#import "OHHTTPStubs.h"
#import "HabiticaTests-Swift.h"

@implementation HabiticaTests

- (void) setUpStubs {
}

- (void)setUp {
    [super setUp];
}

- (void)initializeCoreDataStorage {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.habitrpg.ios.Habitica"];
    
    [HRPGManager setupTestManager];
}


- (void)tearDown {
    [super tearDown];
}



@end
