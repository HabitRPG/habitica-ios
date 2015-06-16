//
//  HRPGTaskTests.m
//  Habitica
//
//  Created by Phillip Thelen on 16/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDate+NSDateMock.h"
#import <objc/runtime.h>
#import "Task.h"

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
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HabitRPG" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    self.task.text = @"None";
    self.task.frequency = @"weekly";
    self.task.saturday = [NSNumber numberWithBool:NO];
    self.task.sunday = [NSNumber numberWithBool:YES];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTodayNotDue {
    [NSDate setMockDate:@"2015/06/20 20:00:00"];
    XCTAssertFalse([self.task dueToday], @"not due on day where not due");
}

- (void)testTodayDue {
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    XCTAssert([self.task dueToday], @"due on day where due");
}

- (void)testTodayNotDueWithOffset {
    [NSDate setMockDate:@"2015/06/20 20:00:00"];
    XCTAssertFalse([self.task dueTodayWithOffset:5], @"not due on day where not due after offset");
}

- (void)testTodayDueWithOffset {
    [NSDate setMockDate:@"2015/06/21 20:00:00"];
    XCTAssert([self.task dueTodayWithOffset:5], @"due on day where due after offset");
}

- (void)testNotTodayNotDueWithOffset {
    [NSDate setMockDate:@"2015/06/21 2:00:00"];
    XCTAssertFalse([self.task dueTodayWithOffset:5], @"not due on day where due before offset");
}

- (void)testNotTodayDueWithOffset {
    [NSDate setMockDate:@"2015/06/22 2:00:00"];
    XCTAssert([self.task dueTodayWithOffset:5], @"due on day where not due before offset");
}

@end
