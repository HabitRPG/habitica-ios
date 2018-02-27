//
//  HRPGTaskFormViewControllerTests.m
//  Habitica
//
//  Created by Phillip Thelen on 20/08/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HRPGFormVIewController.h"
#import "HabiticaTests.h"
#import "XLForm.h"

@interface HRPGTaskFormViewControllerTests : HabiticaTests

@property HRPGFormViewController *viewController;

@end

@implementation HRPGTaskFormViewControllerTests


- (void)setUp {
    [super setUp];
    [self initializeCoreDataStorage];
    self.viewController = [[HRPGFormViewController alloc] initWithCoder:nil];
    self.viewController.managedObjectContext = [[HRPGManager sharedManager] getManagedObjectContext];
}

- (void) presentForm {
    [self.viewController viewDidLoad];
    [self.viewController viewWillAppear:YES];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItCreatesNewFormForHabits {
    //given
    self.viewController.taskType = @"habit";
    
    //when
    [self presentForm];
    
    //then
    UITableView *tableView = self.viewController.tableView;
    XLFormDescriptor *formDescriptor = self.viewController.form;
    XCTAssertEqual([tableView numberOfRowsInSection:0], 4);
    XCTAssertEqual(tableView.numberOfSections, 3);
    XCTAssert([((XLFormSectionDescriptor*)formDescriptor.formSections[1]).title isEqualToString:@"Actions"]);
}

- (void) testThatItCreatesNewFormForDailies {
    //given
    self.viewController.taskType = @"daily";
    
    //when
    [self presentForm];
    
    //then
    UITableView *tableView = self.viewController.tableView;
    XCTAssertEqual(tableView.numberOfSections, 5);
    XCTAssertEqual([tableView numberOfRowsInSection:0], 4);
    XCTAssertEqual([tableView numberOfRowsInSection:2], 9);
}

- (void) testThatItCreatesNewFormForTodos {
    //given
    self.viewController.taskType = @"todo";
    
    //when
    [self presentForm];
    
    //then
    UITableView *tableView = self.viewController.tableView;
    XCTAssertEqual(tableView.numberOfSections, 5);
}

- (void) testThatItCreatesEditFormForHabits {
    //given
    Task *habit = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    habit.type = @"habit";
    habit.text = @"test";
    habit.notes = @"notes";
    habit.priority = @1.5;
    habit.up = @YES;
    habit.down = @NO;
    self.viewController.task = habit;
    self.viewController.taskType = @"habit";
    self.viewController.editTask = YES;
    
    //when
    [self presentForm];
    
    //then
    XLFormDescriptor *form = self.viewController.form;
    NSDictionary *formData = [form formValues];
    XCTAssertEqual(self.viewController.tableView.numberOfSections, 3);
    XCTAssertEqualObjects([formData[@"text"] valueData], @"test");
    XCTAssertEqualObjects([formData[@"notes"] valueData], @"notes");
    XCTAssertEqualObjects([formData[@"priority"] valueData], @1.5F);
    XCTAssertEqualObjects([formData[@"up"] valueData], @YES);
    XCTAssertEqualObjects([formData[@"down"] valueData], @NO);
}

- (void) testThatItCreatesEditFormForWeeklyDailies {
    //given
    Task *daily = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    daily.type = @"daily";
    daily.text = @"test";
    daily.notes = @"notes";
    daily.priority = @1.5;
    daily.frequency = @"weekly";
    daily.monday = @YES;
    daily.tuesday = @NO;
    self.viewController.task = daily;
    self.viewController.taskType = @"daily";
    self.viewController.editTask = YES;
    
    //when
    [self presentForm];
    
    //then
    XLFormDescriptor *form = self.viewController.form;
    NSDictionary *formData = [form formValues];
    XCTAssertEqual(self.viewController.tableView.numberOfSections, 5);
    XCTAssertEqualObjects([formData[@"text"] valueData], @"test");
    XCTAssertEqualObjects([formData[@"notes"] valueData], @"notes");
    XCTAssertEqualObjects([formData[@"priority"] valueData], @1.5F);
    XCTAssertEqualObjects([formData[@"frequency"] valueData], @"weekly");
    XCTAssertEqualObjects([formData[@"monday"] valueData], @YES);
    XCTAssertEqualObjects([formData[@"tuesday"] valueData], @NO);
}

- (void) testThatItCreatesEditFormForDailyDailies {
    //given
    Task *daily = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    daily.type = @"daily";
    daily.text = @"test";
    daily.notes = @"notes";
    daily.priority = @1.5;
    daily.frequency = @"daily";
    daily.everyX = @2;
    self.viewController.task = daily;
    self.viewController.taskType = @"daily";
    self.viewController.editTask = YES;
    
    //when
    [self presentForm];
    
    //then
    XLFormDescriptor *form = self.viewController.form;
    NSDictionary *formData = [form formValues];
    XCTAssertEqual(self.viewController.tableView.numberOfSections, 5);
    XCTAssertEqualObjects([formData[@"text"] valueData], @"test");
    XCTAssertEqualObjects([formData[@"notes"] valueData], @"notes");
    XCTAssertEqualObjects([formData[@"priority"] valueData], @1.5F);
    XCTAssertEqualObjects([formData[@"frequency"] valueData], @"daily");
    //XCTAssertEqualObjects([formData[@"everyX"] valueData], [NSNumber numberWithInt:2]);
}

- (void) testThatItCreatesEditFormForTodos {
    //given
    Task *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    todo.type = @"todo";
    todo.text = @"test";
    todo.notes = @"notes";
    todo.priority = @1.5;
    todo.duedate = [NSDate date];
    self.viewController.task = todo;
    self.viewController.taskType = @"todo";
    self.viewController.editTask = YES;
    
    //when
    [self presentForm];
    
    //then
    XLFormDescriptor *form = self.viewController.form;
    NSDictionary *formData = [form formValues];
    XCTAssertEqual(self.viewController.tableView.numberOfSections, 5);
    XCTAssertEqualObjects([formData[@"text"] valueData], @"test");
    XCTAssertEqualObjects([formData[@"notes"] valueData], @"notes");
    XCTAssertEqualObjects([formData[@"priority"] valueData], @1.5F);
    XCTAssertEqualObjects([formData[@"duedate"] valueData], todo.duedate);
}

- (void) testThatItChangesDailyFrequency {
    //given
    Task *daily = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    daily.type = @"daily";
    daily.text = @"test";
    daily.notes = @"notes";
    daily.priority = @1.5;
    daily.frequency = @"weekly";
    daily.monday = @YES;
    daily.tuesday = @NO;
    self.viewController.task = daily;
    self.viewController.taskType = @"daily";
    self.viewController.editTask = YES;
    [self presentForm];
    
    //when
    [self.viewController.form formRowWithTag:@"frequency"].value = @"daily";
    
    //then
    UITableView *tableView = self.viewController.tableView;
    XCTAssertEqual(tableView.numberOfSections, 5);
    //XCTAssertEqual([tableView numberOfRowsInSection:2], 2);
    
    //when
    [self.viewController.form formRowWithTag:@"frequency"].value = @"weekly";
    
    //then
    XCTAssertEqual(tableView.numberOfSections, 5);
    //XCTAssertEqual([tableView numberOfRowsInSection:2], 8);
    
}

@end
