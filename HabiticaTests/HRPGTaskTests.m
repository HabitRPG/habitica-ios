//
//  HRPGTaskTests.m
//  Habitica
//
//  Created by Phillip Thelen on 16/06/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDate+NSDateMock.h"
#import <objc/runtime.h>
#import "Task+CoreDataClass.h"

void SwizzleClassMethod(Class c, SEL orig, SEL new) {
    
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    
    c = object_getClass((id)c);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@interface HRPGTaskTests : XCTestCase
@property NSManagedObjectContext *managedObjectContext;
@property Task *task;
@end

@implementation HRPGTaskTests

+ (void)setUp {
    [super setUp];
    SwizzleClassMethod([NSDate class], @selector(date), @selector(mockCurrentDate));
}

- (void)setUp {
    [super setUp];
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Habitica" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    self.task.text = @"None";
    self.task.frequency = @"weekly";
    self.task.saturday = @NO;
    self.task.sunday = @YES;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testWeeklyTodayNotDue {
    [NSDate setMockDate:@"2015/06/20 20:00:00"];
    XCTAssertFalse([self.task dueToday], @"not due on day where not due");
}

- (void)testWeeklyTodayDue {
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    XCTAssert([self.task dueToday], @"due on day where due");
}

- (void)testWeeklyTodayNotDueWithOffset {
    [NSDate setMockDate:@"2015/06/20 20:00:00"];
    XCTAssertFalse([self.task dueTodayWithOffset:5], @"not due on day where not due after offset");
}

- (void)testWeeklyTodayDueWithOffset {
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    XCTAssert([self.task dueTodayWithOffset:5], @"due on day where due after offset");
}

- (void)testWeeklyNotTodayNotDueWithOffset {
    [NSDate setMockDate:@"2015/06/21 2:00:00"];
    XCTAssertFalse([self.task dueTodayWithOffset:5], @"not due on day where due before offset");
}

- (void)testWeeklyNotTodayDueWithOffset {
    [NSDate setMockDate:@"2015/06/22 2:00:00"];
    XCTAssert([self.task dueTodayWithOffset:5], @"due on day where not due before offset");
}



- (void)testDailyTodayNotDue {
    self.task.frequency = @"daily";
    self.task.everyX = @2;
    [NSDate setMockDate:@"2015/06/20 21:00:00"];
    self.task.startDate = [NSDate date];
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    XCTAssertFalse([self.task dueToday], @"not due on day where not due");
}

- (void)testDailyTodayDue {
    self.task.frequency = @"daily";
    [NSDate setMockDate:@"2015/06/21 0:00:00"];
    self.task.everyX = @2;
    self.task.startDate = [NSDate date];
    XCTAssert([self.task dueToday], @"due on day where due");
}

- (void)testDailyTodayNotDueWithOffset {
    self.task.frequency = @"daily";
    [NSDate setMockDate:@"2015/06/20 0:00:00"];
    self.task.everyX = @2;
    self.task.startDate = [NSDate date];
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    XCTAssertFalse([self.task dueTodayWithOffset:5], @"not due on day where not due after offset");
}

- (void)testDailyTodayDueWithOffset {
    self.task.frequency = @"daily";
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    self.task.everyX = @2;
    self.task.startDate = [NSDate date];
    XCTAssert([self.task dueTodayWithOffset:5], @"due on day where due after offset");
}

- (void)testDailyNotTodayNotDueWithOffset {
    self.task.frequency = @"daily";
    [NSDate setMockDate:@"2015/06/21 2:00:00"];
    self.task.everyX = @2;
    self.task.startDate = [NSDate date];
    [NSDate setMockDate:@"2015/06/22 20:00:00"];
    XCTAssertFalse([self.task dueTodayWithOffset:5], @"not due on day where due before offset");
}

- (void)testDailyNotTodayDueWithOffset {
    self.task.frequency = @"daily";
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    self.task.everyX = @2;
    self.task.startDate = [NSDate date];
    [NSDate setMockDate:@"2015/06/22 2:00:00"];
    XCTAssert([self.task dueTodayWithOffset:5], @"due on day where not due before offset");
}

@end
