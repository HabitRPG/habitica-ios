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
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import "UIColor+LighterDarker.h"
#import "HRPGHabitButtons.h"
#import "HRPGHabitTableViewCell.h"

@interface HRPGHabitTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NIKFontAwesomeIconFactory *iconFactory;
@end

@implementation HRPGHabitTableViewController

@dynamic readableName;
@dynamic typeName;

- (void)viewDidLoad {
    self.readableName = NSLocalizedString(@"Habit", nil);
    self.typeName = @"habit";
    [super viewDidLoad];
    self.iconFactory = [NIKFontAwesomeIconFactory buttonIconFactory];
    self.iconFactory.padded = NO;
    self.iconFactory.size = 12;
    self.iconFactory.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAutomatic;
    
    self.tutorialIdentifier = @"habit";
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"habit"]) {
        return @{@"text": NSLocalizedString(@"Complete Positive Habits to earn gold and experience! Negative Habits will hurt your avatar if you tap them, so avoid them in real life!", nil)};
    }
    return [super getDefinitonForTutorial:tutorialIdentifier];
}

- (void)configureCell:(HRPGHabitTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    Task *task = [self taskAtIndexPath:indexPath];
    
    [cell configureForTask:task];
    
    [cell.buttons onUpAction:^() {
        [self.sharedManager upDownTask:task direction:@"up" onSuccess:nil onError:nil];
    }];
    [cell.buttons onDownAction:^() {
        [self.sharedManager upDownTask:task direction:@"down" onSuccess:nil onError:nil];
    }];
}

@end
