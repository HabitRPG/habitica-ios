//
//  HRPGQuestInvitationViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGQuestDetailViewController.h"
#import "HRPGAppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HRPGQuestDetailViewController ()
@property HRPGManager *sharedManager;
@property UIImage *bossImage;
@end

@implementation HRPGQuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
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
            return 3;
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
        return self.bossImage.size.height;
    } else if (indexPath.section == 0 && indexPath.item == 2) {
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSString *html = [NSString stringWithFormat:@"<span style=\"font-family: Helvetica Neue; font-size: %ld;margin:0\">%@</span>", (long) [[NSNumber numberWithFloat:font.pointSize] integerValue], self.quest.notes];
        NSError *err;
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
                                documentAttributes:nil
                                error:&err];
        return ceilf([attributedText boundingRectWithSize:CGSizeMake(300.0f, CGFLOAT_MAX)
                                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            context:nil].size.height) + 60;
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
        cellIdentifier = @"bossImageCell";
    } else if (indexPath.section == 0 && indexPath.item == 2) {
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
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        __weak UIImageView *imageView = (UIImageView*) [cell viewWithTag:1];
        [manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/quest_%@.png", self.quest.key]]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
             if (image) {
                 self.bossImage = image;
                 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                 imageView.image = self.bossImage;
             }
         }];
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    } else if (indexPath.section == 0 && indexPath.item == 2) {
        UITextView *textView = (UITextView *) [cell viewWithTag:1];
        NSError *err = nil;
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSString *html = [NSString stringWithFormat:@"<span style=\"font-family: Helvetica Neue; font-size: %ld;margin:0\">%@</span>", (long) [[NSNumber numberWithFloat:font.pointSize] integerValue], self.quest.notes];
        textView.attributedText = [[NSAttributedString alloc]
                initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                     options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType}
          documentAttributes:nil
                       error:&err];
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
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
