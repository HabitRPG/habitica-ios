//
//  HRPGDailyTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGDailyTableViewController.h"

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;

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
    self.readableName = NSLocalizedString(@"Daily", nil);
    self.typeName = @"daily";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
