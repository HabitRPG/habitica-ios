//
//  HabiticaTests.h
//  Habitica
//
//  Created by Phillip Thelen on 21/08/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HRPGManager.h"

@interface HabiticaTests : XCTestCase
@property HRPGManager *sharedManager;

-(void)initializeCoreDataStorage;
-(void)setUpStubs;

@end