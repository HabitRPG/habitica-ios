//
//  HRPGQuestInvitationViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 24/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGQuestInvitationViewController.h"
#import "Quest.h"
@interface HRPGQuestInvitationViewController ()

@end

@implementation HRPGQuestInvitationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                              context:nil].size.height;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.item == 0) {
        
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        
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
        cell.textLabel.text = self.quest.notes;
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
