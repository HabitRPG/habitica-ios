//
//  HRPGTavernTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 12/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGTavernTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CRToast.h>

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
        return @{@"text": NSLocalizedString(@"Welcome to the Tavern, a public, all-ages chatroom! Here you can chat about productivity and ask questions. Have fun!", nil)};
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
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[cell viewWithTag:2];
        [indicator startAnimating];
        [UIView animateWithDuration:0.4 animations:^() {
            label.hidden = YES;
            indicator.hidden = NO;
        } completion:^(BOOL completed) {
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
            NSDictionary *options = @{kCRToastTextKey : notificationText,
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000]
                                      };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                        }];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } onError:^() {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InnCell" forIndexPath:indexPath];
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        if ([self.user.preferences.sleep boolValue]) {
            label.text = NSLocalizedString(@"Leave the Inn", nil);
            label.textColor = [UIColor colorWithRed:0.894 green:0.008 blue:0.000 alpha:1.000];
        } else {
            label.text = NSLocalizedString(@"Rest in the Inn", nil);
            label.textColor = [UIColor colorWithRed:0.366 green:0.599 blue:0.014 alpha:1.000];
        }
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[cell viewWithTag:2];
        label.hidden = NO;
        indicator.hidden = YES;
        
        UIImageView *innImageView = (UIImageView*)[cell viewWithTag:3];
        NSString *url = @"https://habitica-assets.s3.amazonaws.com/mobileApp/images/npc_daniel.png";
        if ([self.group.worldDmgTavern boolValue]) {
            url = @"https://habitica-assets.s3.amazonaws.com/mobileApp/images/npc_daniel_broken.png";
        }
        [innImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithContentsOfFile:@"Placeholder"]];

        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

@end
