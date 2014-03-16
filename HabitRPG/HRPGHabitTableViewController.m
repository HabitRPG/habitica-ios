//
//  HRPGHabitTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitTableViewController.h"
#import "Task.h"
#import "HRPGManager.h"

@interface HRPGHabitTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@end

@implementation HRPGHabitTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic sharedManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.readableName = NSLocalizedString(@"Habit", nil);
    self.typeName = @"habit";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)upDownSelected:(UISegmentedControl*)sender {
    UITableViewCell *cell = (UITableViewCell*)[[[sender superview] superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Task *habit = (Task*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *direction;
    if (sender.selectedSegmentIndex == 0 && habit.down) {
            direction = @"down";
    } else {
        direction = @"up";
    }
    
    [self.sharedManager upDownTask:habit direction:direction onSuccess:^ () {
    } onError:^ () {
        [self.sharedManager displayNetworkError];
    }];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIColor *color = [self.sharedManager getColorForValue:task.value];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = task.text;
    label.textColor = color;
    UISegmentedControl *upDownControl = (UISegmentedControl*)[cell viewWithTag:2];
    upDownControl.tintColor = color;
    [upDownControl removeAllSegments];
    if (task.up) {
        [upDownControl insertSegmentWithTitle:@"+" atIndex:0 animated:0];
    }
    if (task.down) {
        [upDownControl insertSegmentWithTitle:@"-" atIndex:0 animated:0];
    }
}


@end
