//
//  HRPGBaseViewController.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "HRPGManager.h"
#import <PDKeychainBindings.h>
#import "HRPGAppDelegate.h"

@interface HRPGBaseViewController ()
@property HRPGManager *sharedManager;
@end

@implementation HRPGBaseViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = self.sharedManager.getManagedObjectContext;
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    
    if ([keyChain stringForKey:@"id"] == nil || [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:navigationController animated:NO completion: nil];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.refreshControl.isRefreshing) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.refreshControl beginRefreshing];
                           [self.refreshControl endRefreshing];
                       });
    }
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
