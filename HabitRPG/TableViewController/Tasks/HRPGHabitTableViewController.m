//
//  HRPGHabitTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGHabitTableViewController.h"
#import "Habitica-Swift.h"

@interface HRPGHabitTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@end

@implementation HRPGHabitTableViewController

@dynamic readableName;
@dynamic typeName;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"Habit", nil);
    self.typeName = @"habit";
    self.dataSource = [[HabitTableViewDataSource alloc] initWithPredicate:[self getPredicate]];
    [super viewDidLoad];

    self.tutorialIdentifier = @"habits";
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"habits"]) {
        return @{
                 @"textList" : @[NSLocalizedString(@"First up is Habits. They can be positive Habits you want to improve or negative Habits you want to quit.", nil),
                                 NSLocalizedString(@"Every time you do a positive Habit, tap the + to get experience and gold!", nil),
                                 NSLocalizedString(@"If you slip up and do a negative Habit, tapping the - will reduce your avatar’s health to help you stay accountable.", nil),
                                 NSLocalizedString(@"Give it a shot! You can explore the other task types through the bottom navigation.", nil)]
        };
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (NSString *)getCellNibName {
    return @"HabitTableViewCell";
}

@end
