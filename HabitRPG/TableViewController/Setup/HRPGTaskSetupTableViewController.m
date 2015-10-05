//
//  HRPGTaskSetupTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTaskSetupTableViewController.h"

@interface HRPGTaskSetupTableViewController ()

@property NSMutableArray *taskGroups;

@property UIView *headerView;

@end

@implementation HRPGTaskSetupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error;
    self.user.lastSetupStep = [NSNumber numberWithLong:self.currentStep];
    [self.managedObjectContext saveToPersistentStore:&error];
    
    self.taskGroups = [NSMutableArray arrayWithObjects:@{@"text": @"Household", @"isActive": @NO}, @{@"text": @"Sports", @"isActive": @NO}, nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    NSString *title = NSLocalizedString(@"Splendid! Now let's set up your tasks so that you can start earning experience and gold.\n\nTo start, which parts of your life do you want to improve?", nil);
    
    CGFloat height = [title boundingRectWithSize:CGSizeMake(self.view.frame.size.width-40, MAXFLOAT)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{
                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                     }
                                                                           context:nil].size.height+10;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height+60)];
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width-40, height)];
    titleView.font = [UIFont systemFontOfSize:16.0];
    titleView.numberOfLines = 0;
    titleView.text = title;
    [self.headerView addSubview:titleView];
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.taskGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *taskGroup = self.taskGroups[indexPath.item];
    cell.textLabel.text = taskGroup[@"text"];
    if ([taskGroup[@"isActive"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *mutableDict = [self.taskGroups[indexPath.item] mutableCopy];
    mutableDict[@"isActive"] = [NSNumber numberWithBool:!(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
    self.taskGroups[indexPath.item] = mutableDict;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)nextStep:(id)sender {
    NSError *error;
    self.user.lastSetupStep = [NSNumber numberWithLong:self.currentStep];
    [self.managedObjectContext saveToPersistentStore:&error];
    
    [self performSegueWithIdentifier:@"MainSegue" sender:self];
}


- (IBAction)previousStep:(id)sender {
    self.user.lastSetupStep = [NSNumber numberWithInteger:self.currentStep-1];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
