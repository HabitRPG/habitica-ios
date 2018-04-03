//
//  HRPGDailyTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGDailyTableViewController.h"
#import "ChecklistItem.h"
#import "HRPGCheckBoxView.h"
#import "Habitica-Swift.h"

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *expandedIndexPath;

@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"Daily", nil);
    self.typeName = @"daily";
    self.dataSource = [DailyTableViewDataSourceInstantiator instantiateWithPredicate:[self getPredicate]];
    [super viewDidLoad];

    self.tutorialIdentifier = @"dailies";
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"dailies"]) {
        return @{
            @"textList" : @[NSLocalizedString(@"Make Dailies for time-sensitive tasks that need to be done on a regular schedule.", nil),
                            NSLocalizedString(@"Be careful — if you miss one, your avatar will take damage overnight. Checking them off consistently brings great rewards!", nil)]
        };
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (NSString *)getCellNibName {
    return @"DailyTableViewCell";
}

@end
