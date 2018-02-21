//
//  HRPGGroupAboutTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 16/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGGroupAboutTableViewController.h"
#import "HRPGGroupFormViewController.h"
#import "HRPGGroupTableViewController.h"
#import "HRPGProfileViewController.h"
#import "UIColor+Habitica.h"
#import "UIViewController+Markdown.h"
#import "NSString+Emoji.h"
#import "Habitica-Swift.h"

@interface HRPGGroupAboutTableViewController ()
@property NSString *replyMessage;

@end

@implementation HRPGGroupAboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 40;

    [self setupBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBarButton {
    UIBarButtonItem *barButton;
    if (self.isLeader) {
        barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                  target:self
                                                                  action:@selector(openGroupForm)];
    } else {
        if ([self.group.isMember boolValue] || [self.group.type isEqualToString:@"party"]) {
            barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Leave", nil)
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(leaveGroup)];
            barButton.tintColor = [UIColor red50];
        } else {
            barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Join", nil)
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(joinGroup)];
            barButton.tintColor = [UIColor green50];
        }
    }
    self.navigationItem.rightBarButtonItem = barButton;
}

- (void)openGroupForm {
    [self performSegueWithIdentifier:@"GroupFormSegue" sender:self];
}

- (void)leaveGroup {
    HabiticaAlertController *alertController =
    [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                        message:nil];
    
    [alertController addCancelActionWithHandler:nil];
    [alertController addActionWithTitle:NSLocalizedString(@"Leave Group", nil) style:UIAlertActionStyleDefault isMainAction:YES handler:^(UIButton * _Nonnull button) {
        [self alertClickedButtonAtIndex:1];
    }];
    [alertController show];
}

- (void)joinGroup {
    __weak HRPGGroupAboutTableViewController *weakSelf = self;
    [[HRPGManager sharedManager] joinGroup:self.group.id
                         withType:self.group.type
                        onSuccess:^() {
                            weakSelf.navigationItem.rightBarButtonItem = nil;
                        } onError:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.group.type isEqualToString:@"guild"]) {
        return 3;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.item == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.attributedText = [self renderMarkdown:self.group.hdescription];
    } else if (indexPath.item == 1) {
        cell =
            [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Leader", nil);
        cell.detailTextLabel.text = [self.group.leader.username stringByReplacingEmojiCheatCodesWithUnicode];
    } else if (indexPath.item == 2) {
        cell =
            [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Gems", nil);
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%.0f", [self.group.balance floatValue] * 4];
    } else if (indexPath.item == 3) {
        cell =
            [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Visibility", nil);
        cell.detailTextLabel.text = [self.group.privacy localizedCapitalizedString];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GroupFormSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        HRPGGroupFormViewController *groupFormController =
            (HRPGGroupFormViewController *)navigationController.topViewController;
        groupFormController.editGroup = YES;
        groupFormController.group = self.group;
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGGroupFormViewController *formViewController = segue.sourceViewController;
    __weak HRPGGroupAboutTableViewController *weakSelf = self;
    [[HRPGManager sharedManager]
        updateGroup:formViewController.group
          onSuccess:^() {
              if ([weakSelf.presentingViewController
                          .class isSubclassOfClass:HRPGGroupTableViewController.class]) {
                  HRPGGroupTableViewController *vc =
                      (HRPGGroupTableViewController *)weakSelf.presentingViewController;
                  self.group = vc.group;
                  [self.tableView reloadData];
              }
          } onError:nil];
}

- (void)alertClickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        __weak HRPGGroupAboutTableViewController *weakSelf = self;
        [[HRPGManager sharedManager]
            leaveGroup:self.group
              withType:self.group.type
             onSuccess:^() {
                 for (UIViewController *aViewController in
                      [NSMutableArray arrayWithArray:[weakSelf.navigationController viewControllers]]) {
                     if ([aViewController isKindOfClass:[HRPGProfileViewController class]]) {
                         [self.navigationController popToViewController:aViewController
                                                               animated:NO];
                     }
                 }
             }
               onError:nil];
    }
}

@end
