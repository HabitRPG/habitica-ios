//
//  HRPGQuestInvitationViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGQuestInvitationViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "Quest.h"
@interface HRPGQuestInvitationViewController ()
@property HRPGManager *sharedManager;
@end

@implementation HRPGQuestInvitationViewController

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 3;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 1) {
        return [self.quest.notes boundingRectWithSize:CGSizeMake(280.0f, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{
                                                    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                    }
                                              context:nil].size.height+24;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 0) {
        [_sharedManager acceptQuest:self.party.id withQuest:nil useForce:NO onSuccess:^(){
            
        }onError:^(){
            
        }];
        [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        [_sharedManager rejectQuest:self.party.id onSuccess:^(){
            
        }onError:^(){
            
        }];
        [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
    } else if (indexPath.section == 1 && indexPath.item == 2) {
        [self.sourceViewcontroller dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
        textLabel.text = self.quest.notes;
    }
    return cell;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
