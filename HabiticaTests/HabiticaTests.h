//
//  HabiticaTests.h
//  HabiticaTests
//
//  Created by Elliot Schrock on 1/26/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HRPGManager.h"
#import "FBSnapshotTestCase/FBSnapshotTestCase.h"


@interface HabiticaTests : FBSnapshotTestCase

-(void)initializeCoreDataStorage;
-(void)setUpStubs;

@end
