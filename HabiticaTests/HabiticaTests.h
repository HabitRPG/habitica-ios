//
//  HabiticaTests.h
//  Habitica
//
//  Created by Phillip Thelen on 21/08/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HRPGManager.h"
#import "FBSnapshotTestCase/FBSnapshotTestCase.h"

@interface HabiticaTests : FBSnapshotTestCase
@property HRPGManager *sharedManager;

-(void)initializeCoreDataStorage;
-(void)setUpStubs;

@end
