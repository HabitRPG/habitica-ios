//
//  HRPGTaskSetupTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTaskSetupTableViewController.h"
#import <Google/Analytics.h>
#import "Task.h"
#import "ChecklistItem.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@interface HRPGTaskSetupTableViewController ()

@property NSMutableArray *taskGroups;

@property UIView *headerView;
@property NSDictionary *tasks;

@end

@implementation HRPGTaskSetupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    NSError *error;
    self.user.lastSetupStep = [NSNumber numberWithLong:self.currentStep];
    [self.managedObjectContext saveToPersistentStore:&error];
    
    self.taskGroups = [NSMutableArray arrayWithObjects:@{@"text": NSLocalizedString(@"Work", nil), @"identifier": @"work", @"isActive": @NO},
                       @{@"text": NSLocalizedString(@"Exercise", nil), @"identifier": @"exercise", @"isActive": @NO},
                       @{@"text": NSLocalizedString(@"Health + Wellness", nil), @"identifier": @"healthWellness", @"isActive": @NO},
                       @{@"text": NSLocalizedString(@"School", nil),@"identifier": @"school",  @"isActive": @NO},
                       @{@"text": NSLocalizedString(@"Teams", nil), @"identifier": @"teams", @"isActive": @NO},
                       @{@"text": NSLocalizedString(@"Chores", nil), @"identifier": @"chores", @"isActive": @NO},
                       @{@"text": NSLocalizedString(@"Creativity", nil), @"identifier": @"creativity", @"isActive": @NO}, nil];
    
    self.tasks = @{
                   @"work": @[
                           @{
                               @"text": NSLocalizedString(@"Process email", nil),
                               @"up": @YES,
                               @"down": @NO,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Most important task", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Work project", nil),
                               @"type": @"todo"
                               }
                           ],
                   @"exercise": @[
                           @{
                               @"text": NSLocalizedString(@"10 min cardio", nil),
                               @"up": @YES,
                               @"down": @NO,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Stretching", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Set up workout schedule", nil),
                               @"type": @"todo"
                               }
                           ],
                   @"healthWellness": @[
                           @{
                               @"text": NSLocalizedString(@"Eat healthy/junk food", nil),
                               @"up": @YES,
                               @"down": @YES,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Floss", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Schedule check-up", nil),
                               @"type": @"todo"
                               }
                           ],
                   @"school": @[
                           @{
                               @"text": NSLocalizedString(@"Study/Procrastinate", nil),
                               @"up": @YES,
                               @"down": @YES,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Do homework", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Finish assignment for class ", nil),
                               @"type": @"todo"
                               }
                           ],
                   @"teams": @[
                           @{
                               @"text": NSLocalizedString(@"Check in with team", nil),
                               @"up": @YES,
                               @"down": @NO,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Update team on status", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Complete Team Project", nil),
                               @"type": @"todo"
                               }
                           ],
                   @"chores": @[
                           @{
                               @"text": NSLocalizedString(@"10 minutes cleaning", nil),
                               @"up": @YES,
                               @"down": @NO,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Wash Dishes", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Organize Closet", nil),
                               @"type": @"todo"
                               }
                           ],
                   @"creativity": @[
                           @{
                               @"text": NSLocalizedString(@"Study a master of the craft", nil),
                               @"up": @YES,
                               @"down": @NO,
                               @"type": @"habit"
                               },
                           @{
                               @"text": NSLocalizedString(@"Work on creative project", nil),
                               @"frequency": @"weekly",
                               @"startDate": [NSDate date],
                               @"monday": @YES,
                               @"tuesday": @YES,
                               @"wednesday": @YES,
                               @"thursday": @YES,
                               @"friday": @YES,
                               @"saturday": @YES,
                               @"sunday": @YES,
                               @"type": @"daily"
                               },
                           @{
                               @"text": NSLocalizedString(@"Finish creative project", nil),
                               @"type": @"todo"
                               }
                           ]
                   };
    
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
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *manager = appdelegate.sharedManager;
    
    for (NSDictionary *taskGroup in self.taskGroups) {
        if ([taskGroup[@"isActive"] boolValue]) {
            for (NSDictionary *taskDictionary in self.tasks[taskGroup[@"identifier"]]) {
                Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
                task.text = taskDictionary[@"text"];
                task.type = taskDictionary[@"type"];
                task.priority = @1;
                if ([task.type isEqualToString:@"habit"]) {
                    task.up = taskDictionary[@"up"];
                    task.down = taskDictionary[@"down"];
                } else if ([task.type isEqualToString:@"daily"]) {
                    task.frequency = taskDictionary[@"frequency"];
                    task.startDate = [NSDate date];
                    task.monday = taskDictionary[@"monday"];
                    task.tuesday = taskDictionary[@"tuesday"];
                    task.wednesday = taskDictionary[@"wednesday"];
                    task.thursday = taskDictionary[@"thursday"];
                    task.friday = taskDictionary[@"friday"];
                    task.saturday = taskDictionary[@"saturday"];
                    task.sunday = taskDictionary[@"sunday"];
                } else {
                    for (NSDictionary *checklistItemDictionary in taskDictionary[@"checklist"]) {
                        ChecklistItem *checklistItem = [NSEntityDescription insertNewObjectForEntityForName:@"ChecklistItem" inManagedObjectContext:self.managedObjectContext];
                        checklistItem.text = checklistItemDictionary[@"text"];
                        [task addChecklistObject:checklistItem];
                    }
                }
                
                [manager createTask:task onSuccess:^() {
                    
                } onError:^() {
                    
                }];
            }
        }
    }
    
    [self.managedObjectContext saveToPersistentStore:&error];
    
    if (self.shouldDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"MainSegue" sender:self];
    }}


- (IBAction)previousStep:(id)sender {
    self.user.lastSetupStep = [NSNumber numberWithInteger:self.currentStep-1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainSegue"]) {
        UITabBarController *tabBarController = segue.destinationViewController;
        [tabBarController setSelectedIndex:2];
    }
}

@end
