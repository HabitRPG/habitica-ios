//
//  HRPGSpellTaskController.m
//  Habitica
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGSpellTaskController.h"
#import "HRPGSpellTabBarController.h"
#import "NSString+Emoji.h"
#import "Habitica-Swift.h"

@interface HRPGSpellTaskController ()

@end

@implementation HRPGSpellTaskController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.taskType isEqualToString:@"habit"]) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 50, 0);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname = @"Cell";
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    cell.textLabel.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    cell.backgroundColor = [task lightTaskColor];
    if (task.challengeID) {
        cell.detailTextLabel.text = NSLocalizedString(@"Can't cast a spell on a challenge task.", nil);
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    float width = self.viewWidth - 40;
    NSInteger height = [task.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                NSFontAttributeName : [UIFont
                                                    preferredFontForTextStyle:UIFontTextStyleBody]
                                            }
                                               context:nil]
                           .size.height +
                       45;
    if (task.duedate) {
        height = height + 5;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Task *task = (Task *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (task.challengeID) {
        return;
    }
    HRPGSpellTabBarController *tabBarController =
        (HRPGSpellTabBarController *)self.parentViewController;
    tabBarController.taskID = task.id;
    [tabBarController castSpell];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate;
    if ([self.taskType isEqual:@"todo"]) {
        predicate = [NSPredicate predicateWithFormat:@"type=='todo' && completed==NO"];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"type==%@", self.taskType];
    }
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

@end
