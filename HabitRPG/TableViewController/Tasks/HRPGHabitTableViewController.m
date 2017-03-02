//
//  HRPGHabitTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitTableViewController.h"
#import "HRPGHabitButtons.h"
#import "HRPGHabitTableViewCell.h"

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
            @"text" : NSLocalizedString(@"Complete Positive Habits to earn gold and experience! "
                                        @"Negative Habits will hurt your avatar if you tap them, "
                                        @"so avoid them in real life!",
                                        nil)
        };
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (void)configureCell:(HRPGHabitTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];

    [cell configureForTask:task];

    __weak HRPGHabitTableViewController *weakSelf = self;
    [cell.plusButton action:^() {
        [weakSelf.sharedManager upDownTask:task direction:@"up" onSuccess:nil onError:nil];
    }];
    [cell.minusButton action:^() {
        [weakSelf.sharedManager upDownTask:task direction:@"down" onSuccess:nil onError:nil];
    }];
}

- (NSString *)getCellNibName {
    return @"HRPGHabitTableViewCell";
}

@end
