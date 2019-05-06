//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGSpellViewController.h"
#import "HRPGSpellTabBarController.h"
#import "Habitica-Swift.h"

@interface HRPGSpellViewController ()
@property id<SpellsTableViewDataSourceProtocol> dataSource;
@end

@implementation HRPGSpellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = objcL10n.titleSkills;    
    
    [self setupTableView];
    self.tutorialIdentifier = @"skills";
}

- (void) setupTableView {
    self.dataSource = [SpellsTableViewDataSourceInstantiator instantiate];
    self.dataSource.tableView = self.tableView;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 95;
    self.tableView.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"skills"]) {
        return @{
            @"text" : objcL10n.tutorialSpells
        };
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id skill = [self.dataSource skillAtIndexPath:indexPath];
    if (skill != nil) {
        if ([self.dataSource canUseWithSkill:skill] && [self.dataSource hasManaForSkill:skill]) {
            NSString *target = [skill valueForKey:@"target"];
            if ([target isEqualToString:@"task"]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *navigationController = [storyboard
                                                                instantiateViewControllerWithIdentifier:@"spellTaskNavigationController"];
                
                [self presentViewController:navigationController
                                   animated:YES
                                 completion:^() {
                                     HRPGSpellTabBarController *tabBarController =
                                     (HRPGSpellTabBarController *)
                                     navigationController.topViewController;
                                     tabBarController.skill = skill;
                                     tabBarController.sourceTableView = self.tableView;
                                 }];
            } else {
                [self.dataSource useSkillWithSkill:skill targetId:nil];
            }
        }
        return;
    }
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if (item != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navigationController = [storyboard
                                                        instantiateViewControllerWithIdentifier:@"SpellUserNavigationController"];
        [self presentViewController:navigationController
                           animated:YES
                         completion:^() {
                             SkillsUserTableViewController *viewController =
                             (SkillsUserTableViewController *)
                             navigationController.topViewController;
                             viewController.skill = item;
                         }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}


- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"CastUserSpellSegue"]) {
        SkillsUserTableViewController *userViewController = (SkillsUserTableViewController *) segue.sourceViewController;
        [self.dataSource useItemWithItem:userViewController.skill targetId:userViewController.selectedUserID];
    } else if ([segue.identifier isEqualToString:@"CastTaskSpellSegue"]) {
        HRPGSpellTabBarController *tabbarController = (HRPGSpellTabBarController *) segue.sourceViewController;
        [self.dataSource useSkillWithSkill:tabbarController.skill targetId:tabbarController.taskID];
    }
}
@end
