//
//  HRPGHabitTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitTableViewController.h"
#import "HRPGHabitButtons.h"
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

- (void)configureCell:(HabitTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];

    [cell configureWithTask:task];

    __weak HRPGHabitTableViewController *weakSelf = self;
    [cell.plusButton action:^() {
        [weakSelf.sharedManager upDownTask:task direction:@"up" onSuccess:nil onError:nil];
    }];
    [cell.minusButton action:^() {
        [weakSelf.sharedManager upDownTask:task direction:@"down" onSuccess:nil onError:nil];
    }];
}

- (NSString *)getCellNibName {
    return @"HabitTableViewCell";
}

@end
