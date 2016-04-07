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

@end
