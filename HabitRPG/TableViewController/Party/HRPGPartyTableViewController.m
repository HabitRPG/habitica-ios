//
//  HRPGPartyTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGPartyTableViewController.h"

@interface HRPGPartyTableViewController ()

@end

@implementation HRPGPartyTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.groupID = [defaults objectForKey:@"partyID"];
        self.tutorialIdentifier = @"party";
    }
    
    return self;
}

- (bool)listMembers {
    return YES;
}

- (void)refresh {
    [self.sharedManager fetchGroup:@"party" onSuccess:^() {
        [self.refreshControl endRefreshing];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.groupID = [defaults objectForKey:@"partyID"];
        [self fetchGroup];
    } onError:^() {
        [self.refreshControl endRefreshing];
        [self.sharedManager displayNetworkError];
    }];
}

- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    return [self.tableView convertRect:cell.frame toView:self.parentViewController.parentViewController.view];
}


- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"party"]) {
        return @{@"text": NSLocalizedString(@"This is where you and your friends can hold each other accountable to your goals and fight monsters with your tasks!", nil)};
    } else if ([tutorialIdentifier isEqualToString:@"inviteParty"]) {
        return @{@"text": NSLocalizedString(@"Tap to invite friends and view party members.", nil)};
    }
    return nil;
}

- (bool)canInviteToQuest {
    return YES;
}

@end
