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
#import "HRPGCheckBoxView.h"
#import "UIColor+Habitica.h"
#import "HRPGBatchOperation.h"
#import "Amplitude.h"

@interface HRPGTaskSetupTableViewController ()

@property NSMutableArray *taskGroups;

@property UIView *headerView;
@property UIImageView *avatarView;
@property NSDictionary *tasks;
@property(weak, nonatomic) IBOutlet UIView *gradientView;

@end

@implementation HRPGTaskSetupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:@"pageview" forKey:@"hitType"];
    [eventProperties setValue:NSStringFromClass([self class]) forKey:@"page"];
    [[Amplitude instance] logEvent:@"navigate" withEventProperties:eventProperties];

    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];

    self.taskGroups =
        [NSMutableArray arrayWithObjects:@{
            @"text" : NSLocalizedString(@"Work", nil),
            @"identifier" : @"work",
            @"isActive" : @NO
        },
                                         @{
                                             @"text" : NSLocalizedString(@"Exercise", nil),
                                             @"identifier" : @"exercise",
                                             @"isActive" : @NO
                                         },
                                         @{
                                             @"text" : NSLocalizedString(@"Health + Wellness", nil),
                                             @"identifier" : @"healthWellness",
                                             @"isActive" : @NO
                                         },
                                         @{
                                             @"text" : NSLocalizedString(@"School", nil),
                                             @"identifier" : @"school",
                                             @"isActive" : @NO
                                         },
                                         @{
                                             @"text" : NSLocalizedString(@"Teams", nil),
                                             @"identifier" : @"teams",
                                             @"isActive" : @NO
                                         },
                                         @{
                                             @"text" : NSLocalizedString(@"Chores", nil),
                                             @"identifier" : @"chores",
                                             @"isActive" : @NO
                                         },
                                         @{
                                             @"text" : NSLocalizedString(@"Creativity", nil),
                                             @"identifier" : @"creativity",
                                             @"isActive" : @NO
                                         },
                                         nil];

    self.tasks = @{
        @"work" : @[
            @{
               @"text" : NSLocalizedString(@"Process email", nil),
               @"up" : @YES,
               @"down" : @NO,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Most important task", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{@"text" : NSLocalizedString(@"Work project", nil), @"type" : @"todo"}
        ],
        @"exercise" : @[
            @{
               @"text" : NSLocalizedString(@"10 min cardio", nil),
               @"up" : @YES,
               @"down" : @NO,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Stretching", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{@"text" : NSLocalizedString(@"Set up workout schedule", nil), @"type" : @"todo"}
        ],
        @"healthWellness" : @[
            @{
               @"text" : NSLocalizedString(@"Eat healthy/junk food", nil),
               @"up" : @YES,
               @"down" : @YES,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Floss", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{@"text" : NSLocalizedString(@"Schedule check-up", nil), @"type" : @"todo"}
        ],
        @"school" : @[
            @{
               @"text" : NSLocalizedString(@"Study/Procrastinate", nil),
               @"up" : @YES,
               @"down" : @YES,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Do homework", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{
               @"text" : NSLocalizedString(@"Finish assignment for class ", nil),
               @"type" : @"todo"
            }
        ],
        @"teams" : @[
            @{
               @"text" : NSLocalizedString(@"Check in with team", nil),
               @"up" : @YES,
               @"down" : @NO,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Update team on status", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{@"text" : NSLocalizedString(@"Complete Team Project", nil), @"type" : @"todo"}
        ],
        @"chores" : @[
            @{
               @"text" : NSLocalizedString(@"10 minutes cleaning", nil),
               @"up" : @YES,
               @"down" : @NO,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Wash Dishes", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{@"text" : NSLocalizedString(@"Organize Closet", nil), @"type" : @"todo"}
        ],
        @"creativity" : @[
            @{
               @"text" : NSLocalizedString(@"Study a master of the craft", nil),
               @"up" : @YES,
               @"down" : @NO,
               @"type" : @"habit"
            },
            @{
               @"text" : NSLocalizedString(@"Work on creative project", nil),
               @"frequency" : @"weekly",
               @"startDate" : [NSDate date],
               @"monday" : @YES,
               @"tuesday" : @YES,
               @"wednesday" : @YES,
               @"thursday" : @YES,
               @"friday" : @YES,
               @"saturday" : @YES,
               @"sunday" : @YES,
               @"type" : @"daily"
            },
            @{@"text" : NSLocalizedString(@"Finish creative project", nil), @"type" : @"todo"}
        ]
    };

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];

    NSString *title = NSLocalizedString(@"Splendid! Now let's set up your tasks so that you can "
                                        @"start earning experience and gold.\n\nTo start, which "
                                        @"parts of your life do you want to improve?",
                                        nil);

    CGFloat height =
        [title boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 140, MAXFLOAT)
                            options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{
                             NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                         }
                            context:nil]
            .size.height +
        10;
    if (height < 90) {
        height = 90;
    }
    self.headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height + 30)];
    UILabel *titleView = [[UILabel alloc]
        initWithFrame:CGRectMake(110, 20, self.view.frame.size.width - 140, height)];
    titleView.font = [UIFont systemFontOfSize:16.0];
    titleView.numberOfLines = 0;
    titleView.textAlignment = NSTextAlignmentJustified;
    titleView.text = title;
    [self.headerView addSubview:titleView];

    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 90, height)];
    self.avatarView.contentMode = UIViewContentModeCenter;
    [self.user setAvatarOnImageView:self.avatarView withPetMount:NO onlyHead:NO useForce:NO];
    [self.headerView addSubview:self.avatarView];

    self.tableView.tableHeaderView = self.headerView;

    self.tableView.tableFooterView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];

    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.gradientView.bounds;
    layer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor,
                                             (id)[UIColor colorWithWhite:1 alpha:0].CGColor, nil];
    layer.startPoint = CGPointMake(1.0f, 0.75f);
    layer.endPoint = CGPointMake(1.0f, 0.0f);
    [self.gradientView.layer insertSublayer:layer atIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.taskGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *taskGroup = self.taskGroups[indexPath.item];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    HRPGCheckBoxView *checkboxView = (HRPGCheckBoxView *)[cell viewWithTag:2];
    textLabel.text = taskGroup[@"text"];
    checkboxView.cornerRadius = checkboxView.size / 2;
    if ([taskGroup[@"isActive"] boolValue]) {
        checkboxView.checkColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        checkboxView.boxBorderColor = [UIColor purple300];
        checkboxView.boxFillColor = [UIColor purple300];
    } else {
        checkboxView.boxFillColor = [UIColor clearColor];
        checkboxView.boxBorderColor = [UIColor purple300];
        checkboxView.checkColor = [UIColor purple300];
    }
    checkboxView.checked = [taskGroup[@"isActive"] boolValue];
    checkboxView.userInteractionEnabled = NO;
    [checkboxView setNeedsDisplay];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *mutableDict = [self.taskGroups[indexPath.item] mutableCopy];
    mutableDict[@"isActive"] = [NSNumber numberWithBool:!([mutableDict[@"isActive"] boolValue])];
    self.taskGroups[indexPath.item] = mutableDict;
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)nextStep:(id)sender {
    NSError *error;
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
    HRPGManager *manager = appdelegate.sharedManager;
    NSMutableArray *actions = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for (NSDictionary *taskGroup in self.taskGroups) {
        if ([taskGroup[@"isActive"] boolValue]) {
            for (NSDictionary *taskDictionary in self.tasks[taskGroup[@"identifier"]]) {
                NSMutableDictionary *mutableTaskDictionary = [taskDictionary mutableCopy];
                mutableTaskDictionary[@"priority"] = @1;
                if ([taskDictionary[@"type"] isEqualToString:@"daily"]) {
                    mutableTaskDictionary[@"startDate"] =
                        [dateFormatter stringFromDate:[NSDate date]];
                    mutableTaskDictionary[@"notes"] = NSLocalizedString(
                        @"Tap to edit task, change notification time, or delete.", nil);
                }
                HRPGBatchOperation *batchOperation = [[HRPGBatchOperation alloc] init];
                batchOperation.op = @"addTask";
                batchOperation.body = mutableTaskDictionary;
                [actions addObject:batchOperation];
            }
        }
    }

    [manager batchUpdateUser:actions onSuccess:nil onError:nil];

    [self.managedObjectContext saveToPersistentStore:&error];

    if (self.shouldDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"MainSegue" sender:self];
    }
}

- (IBAction)previousStep:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainSegue"]) {
        UITabBarController *tabBarController = segue.destinationViewController;
        [tabBarController setSelectedIndex:2];
    }
}

@end
