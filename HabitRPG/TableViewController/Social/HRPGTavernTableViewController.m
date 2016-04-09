//
//  HRPGTavernTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 12/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGTavernTableViewController.h"
#import <CRToast.h>
#import "UIColor+Habitica.h"

@interface HRPGTavernTableViewController ()

@end

@implementation HRPGTavernTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.groupID = @"habitrpg";
        self.tutorialIdentifier = @"tavern";
    }

    return self;
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"tavern"]) {
        return @{
            @"text" :
                NSLocalizedString(@"Welcome to the Tavern, a public, all-ages chatroom! Here you "
                                  @"can chat about productivity and ask questions. Have fun!",
                                  nil)
        };
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.group && indexPath.section == 0 && indexPath.item == 0) {
        return 123;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.group && indexPath.section == 0 && indexPath.item == 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell viewWithTag:2];
        [indicator startAnimating];
        [UIView animateWithDuration:0.4
            animations:^() {
                label.hidden = YES;
                indicator.hidden = NO;
            }
            completion:^(BOOL completed) {
                if (completed) {
                }
            }];
        [self.sharedManager sleepInn:^() {
            NSString *notificationText;
            if ([self.user.preferences.sleep boolValue]) {
                notificationText = NSLocalizedString(@"Sleep tight!", nil);
            } else {
                notificationText = NSLocalizedString(@"Wakey Wakey!", nil);
            }
            NSDictionary *options = @{
                kCRToastTextKey : notificationText,
                kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                kCRToastBackgroundColorKey : [UIColor green50]
            };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                        }];
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
            onError:^() {
                [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                                      withRowAnimation:UITableViewRowAnimationFade];
            }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"InnCell" forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        if ([self.user.preferences.sleep boolValue]) {
            label.text = NSLocalizedString(@"Leave the Inn", nil);
            label.textColor = [UIColor red100];
        } else {
            label.text = NSLocalizedString(@"Rest in the Inn", nil);
            label.textColor = [UIColor green100];
        }
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell viewWithTag:2];
        label.hidden = NO;
        indicator.hidden = YES;

        UIImageView *innImageView = (UIImageView *)[cell viewWithTag:3];
        NSString *url = @"npc_daniel";
        if ([self.group.worldDmgTavern boolValue]) {
            url = @"npc_daniel_broken";
        }
        [self.sharedManager setImage:url withFormat:@"png" onView:innImageView];
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

@end
