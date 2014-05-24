//
//  HRPGSpellTaskController.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSpellTaskController.h"
#import "Task.h"
#import "NSString+Emoji.h"
#import "HRPGSpellTabBarController.h"

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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname = @"Cell";
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    cell.textLabel.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    float width = 280.0f;
    NSInteger height = [task.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                            }
                                               context:nil].size.height + 35;
    if (task.duedate) {
        height = height + 5;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HRPGSpellTabBarController *tabBarController = (HRPGSpellTabBarController *) self.parentViewController;
    Task *task = (Task *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    tabBarController.taskID = task.id;
    [tabBarController castSpell];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate;
    if ([self.taskType isEqual:@"todo"]) {
        predicate = [NSPredicate predicateWithFormat:@"type=='todo' && completed==NO"];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"type==%@", self.taskType];
    }
    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}


@end
