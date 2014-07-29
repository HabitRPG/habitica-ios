//
//  HRPGQuestInvitationViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGQuestDetailViewController.h"
#import "HRPGAppDelegate.h"

@interface HRPGQuestDetailViewController ()
@property HRPGManager *sharedManager;
@end

@implementation HRPGQuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    _sharedManager = appdelegate.sharedManager;
    if (self.party.questKey != nil && ![self.party.questActive boolValue] && self.user.participateInQuest == nil) {
        self.navigationItem.title = NSLocalizedString(@"Quest Invitation", nil);
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.title = NSLocalizedString(@"Quest Detail", nil);
        if ([self.party.questActive boolValue] && [self.party.questLeader isEqualToString:self.user.id]) {
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Abort", nil);
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.894 green:0.008 blue:0.000 alpha:1.000];
        } else if ([self.party.questActive boolValue] || ![self.party.questLeader isEqualToString:self.user.id]) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ((![self.isWorldQuest boolValue]) && self.party.questKey != nil && ![self.party.questActive boolValue] && self.user.participateInQuest == nil) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            if ([self.hideAskLater boolValue]) {
                return 2;
            }
            return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return [self.quest.text boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                                        }
                                              context:nil].size.height + 16;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        return [self.quest.notes boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                   NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                           }
                                              context:nil].size.height + 80;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 0) {
        [_sharedManager acceptQuest:self.party.id withQuest:nil useForce:NO onSuccess:^(){

        }                   onError:^(){

        }];
        if (self.wasPushed) {
            [self.tableView reloadData];
        } else {
            [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        [_sharedManager rejectQuest:self.party.id onSuccess:^(){

        }                   onError:^(){

        }];
        if (self.wasPushed) {
            [self.tableView reloadData];
        } else {
            [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (indexPath.section == 1 && indexPath.item == 2) {
        [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    if (indexPath.section == 0 && indexPath.item == 0) {
        cellIdentifier = @"titleCell";
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        cellIdentifier = @"descriptionCell";
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        cellIdentifier = @"acceptCell";
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        cellIdentifier = @"rejectCell";
    } else if (indexPath.section == 1 && indexPath.item == 2) {
        cellIdentifier = @"asklaterCell";
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (indexPath.section == 0 && indexPath.item == 0) {
        cell.textLabel.text = self.quest.text;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        NSError *err = nil;
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSString *html = [NSString stringWithFormat:@"<span style=\"font-family: Helvetica Neue; font-size: %ld\">%@</span>", (long) [[NSNumber numberWithFloat:font.pointSize] integerValue], self.quest.notes];
        label.attributedText = [[NSAttributedString alloc]
                initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                     options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
          documentAttributes:nil
                       error:&err];
    }
    return cell;
}


- (IBAction)forceQuestBegin:(id)sender {
    NSString *message;
    if ([self.party.questActive boolValue]) {
        message = NSLocalizedString(@"When you abort a quest, all progress will be lost and the quest scroll will be put back into your inventory.", nil);
    } else {
        message = NSLocalizedString(@"Once a quest is started, no other party members can join the quest.", nil);
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if ([self.party.questActive boolValue]) {
            [_sharedManager abortQuest:self.party.id onSuccess:^(){
                [self.navigationController popViewControllerAnimated:YES];
            } onError:^(){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }];
        } else {
            [_sharedManager acceptQuest:self.party.id withQuest:nil useForce:YES onSuccess:^(){
                [self.navigationController popViewControllerAnimated:YES];
            } onError:^(){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }];
        }

    }
}

@end
