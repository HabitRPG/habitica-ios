//
//  HRPGQuestGroupTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 12/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGQuestGroupTableViewController.h"
#import "HRPGProgressView.h"
#import "QuestCollect.h"
#import "HRPGQuestParticipantsViewController.h"
#import "HRPGQuestDetailViewController.h"

@interface HRPGQuestGroupTableViewController ()

@end

@implementation HRPGQuestGroupTableViewController

- (int)chatSectionIndex {
    if ([self displayQuestSection]) {
        return 3;
    } else {
        return [super chatSectionIndex];
    }
}

- (bool)canInviteToQuest {
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.group && [self displayQuestSection]) {
        return 4;
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (bool)listMembers {
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isQuestSection:section]) {
        if (self.quest) {
            int extracells;
            if ([self listMembers]) {
                extracells = 2;
            } else {
                extracells = 1;
            }
            if ([self isActiveCollectionQuest]) {
                return [self.quest.collect count] + extracells;
            } else if ([self isActiveBossQuest] && [self.quest.bossRage integerValue] == 0) {
                return 1 + extracells;
            } else if ([self isActiveBossQuest] && [self.quest.bossRage integerValue] > 0) {
                return 2 + extracells;
            } else if (self.group.questKey) {
                return extracells;
            } else {
                return 1;
            }
        } else {
            return 1;
        }
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isQuestSection:indexPath.section]) {
        UITableViewCell *cell;
        NSString *cellname;
        if (self.quest) {
            if (indexPath.item == 0) {
                cellname = @"QuestCell";
            } else if ([self listMembers] && ((indexPath.section == 1 && indexPath.item == 1))) {
                if ([self.group.questActive boolValue]) {
                    cellname = @"BaseCell";
                } else {
                    cellname = @"SubtitleCell";
                }
            } else if ([self isActiveBossQuest]) {
                if ((indexPath.item == 2 && [self listMembers]) || (indexPath.item == 1 && ![self listMembers])) {
                    cellname = @"LifeCell";
                } else if (indexPath.item == 2) {
                    cellname = @"RageCell";
                }
            } else if ([self isActiveCollectionQuest]) {
                cellname = @"CollectItemQuestCell";
            }
        } else {
            if (self.group.questKey == nil) {
                cellname = @"NoQuestCell";
            } else {
                cellname = @"QuestCell";
            }
        }
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
            
            if ([cellname isEqualToString:@"QuestCell"]) {
                cell.textLabel.text = self.quest.text;
            } else if ([self listMembers] && ((indexPath.section == 1 && indexPath.item == 1))) {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                int acceptedCount = 0;
                
                if ([self.group.questActive boolValue]) {
                    for (User *participant in self.group.member) {
                        if ([participant.participateInQuest boolValue]) {
                            acceptedCount++;
                        }
                    }
                    if (acceptedCount == 1) {
                        cell.textLabel.text = NSLocalizedString(@"1 Participant", nil);
                    } else {
                        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Participants", nil), acceptedCount];
                    }
                } else {
                    cell.textLabel.text = NSLocalizedString(@"Participants", nil);
                    for (User *participant in self.group.member) {
                        if (participant.participateInQuest != nil) {
                            acceptedCount++;
                        }
                    }
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d out of %d responded", nil), acceptedCount, [self.group.member count]];
                    
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if ([self isActiveBossQuest]) {
                if ((indexPath.item == 2 && [self listMembers]) || (indexPath.item == 1 && ![self listMembers])) {
                    UILabel *lifeLabel = (UILabel *) [cell viewWithTag:1];
                    lifeLabel.text = [NSString stringWithFormat:@"%@ / %@", self.group.questHP, self.quest.bossHp];
                    lifeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                    HRPGProgressView *lifeBar = (HRPGProgressView *) [cell viewWithTag:2];
                    lifeBar.progress = [NSNumber numberWithFloat:([self.group.questHP floatValue] / [self.quest.bossHp floatValue])];
                } else if (indexPath.item == 2) {
                    UILabel *lifeLabel = (UILabel *) [cell viewWithTag:1];
                    lifeLabel.text = [NSString stringWithFormat:@"%@ / %@", self.group.questRage, self.quest.bossRage];
                    lifeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                    HRPGProgressView *lifeBar = (HRPGProgressView *) [cell viewWithTag:2];
                    lifeBar.progress = [NSNumber numberWithFloat:([self.group.questRage floatValue] / [self.quest.bossRage floatValue])];
                }
            } else if ([self isActiveCollectionQuest]) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                QuestCollect *collect = self.quest.collect[indexPath.item - 2];
                cell.textLabel.text = collect.text;
                if ([collect.count integerValue] == [collect.collectCount integerValue]) {
                    cell.textLabel.textColor = [UIColor grayColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", collect.collectCount, collect.count];
                cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            }
        }
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (bool)displayQuestSection {
    return self.group.questKey || [self canInviteToQuest];
}

- (bool)isQuestSection:(NSInteger)section {
    return [self displayQuestSection] && section == 1;
}

- (bool) isActiveCollectionQuest {
    return [self.group.questActive boolValue] && [self.quest.bossHp integerValue] == 0;
}

- (bool) isActiveBossQuest {
    return [self.group.questActive boolValue] && [self.group.questHP integerValue] > 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"ParticipantsSegue"]) {
        HRPGQuestParticipantsViewController *qpViewcontroller = segue.destinationViewController;
        qpViewcontroller.party = self.group;
        qpViewcontroller.quest = self.quest;
    } else if ([segue.identifier isEqualToString:@"QuestDetailSegue"]) {
        HRPGQuestDetailViewController *qdViewcontroller = segue.destinationViewController;
        qdViewcontroller.quest = self.quest;
        qdViewcontroller.party = self.group;
        qdViewcontroller.user = self.user;
        qdViewcontroller.hideAskLater = [NSNumber numberWithBool:YES];
        qdViewcontroller.wasPushed = [NSNumber numberWithBool:YES];
    }
}

- (Quest *)quest {
    if (!self.group.questKey) {
        _quest = nil;
        return nil;
    }
    if (_quest) {
        return _quest;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quest" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", self.group.questKey]];
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([result count] > 0) {
        _quest = result[0];
        if (!_quest.text) {
            [self.sharedManager fetchContent:^() {
                self.quest = nil;
                [self.tableView reloadData];
            } onError:^() {
                
            }];
        }
    }
    return _quest;
}

@end
