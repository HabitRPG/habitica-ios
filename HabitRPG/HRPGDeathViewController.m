//
//  HRPGQuestInvitationViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGDeathViewController.h"
#import "HRPGAppDelegate.h"

@interface HRPGDeathViewController ()
@property HRPGManager *sharedManager;
@end

@implementation HRPGDeathViewController

NSString *deathNote = @"You've lost a Level, all your Gold, and a random piece of Equipment. Arise, Habiteer, and try again! Curb those negative Habits, be vigilant in completion of Dailies, and hold death at arm's length with a Health Potion if you falter!";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    _sharedManager = appdelegate.sharedManager;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return [deathNote boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                        }
                                              context:nil].size.height+25;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 0) {
        [_sharedManager reviveUser:^(){
            [self dismissViewControllerAnimated:YES completion:nil];
        }onError:^(){
            
        }];
    }
}

@end
