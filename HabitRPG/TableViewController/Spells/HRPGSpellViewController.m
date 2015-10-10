//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSpellViewController.h"
#import "HRPGAppDelegate.h"
#import "Spell.h"
#import "HRPGSpellTabBarController.h"

@interface HRPGSpellViewController ()
@property User *user;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGSpellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
    self.tutorialIdentifier = @"skills";

    if ([self.user.hclass isEqualToString:@"wizard"] || [self.user.hclass isEqualToString:@"healer"]) {
        self.navigationItem.title = NSLocalizedString(@"Cast Spells", nil);
    } else {
        self.navigationItem.title = NSLocalizedString(@"Use Skills", nil);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Spell *spell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.user.magic integerValue] >= [spell.mana integerValue]) {
        if ([spell.target isEqualToString:@"task"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"spellTaskNavigationController"];

            [self presentViewController:navigationController animated:YES completion:^() {
                HRPGSpellTabBarController *tabBarController = (HRPGSpellTabBarController *) navigationController.topViewController;
                tabBarController.spell = spell;
                tabBarController.sourceTableView = self.tableView;
            }];
        } else {
            [self.sharedManager castSpell:spell.key withTargetType:spell.target onTarget:nil onSuccess:^() {
                [tableView reloadData];
            } onError:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 30.0f;
    float width = self.viewWidth-43;
    Spell *spell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    width = width - [[NSString stringWithFormat:@"%ld MP", (long) [spell.mana integerValue]] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                       attributes:@{
                                                                                                               NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                                                                       }
                                                                                                          context:nil].size.width;
    height = height + [spell.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                            }
                                               context:nil].size.height;
    if ([spell.notes length] > 0) {
        height = height + [spell.notes boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                         NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                                 }
                                                    context:nil].size.height;
    }
    return height;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Spell" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    User *user = [self.sharedManager getUser];
    NSString *classname = [NSString stringWithFormat:@"spells.%@", user.dirtyClass];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"klass == %@ && level <= %@", classname, user.level]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    Spell *spell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *) [cell viewWithTag:1];
    UILabel *detailLabel = (UILabel *) [cell viewWithTag:2];
    UILabel *manaLabel = (UILabel *) [cell viewWithTag:3];
    nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    manaLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    nameLabel.text = spell.text;
    detailLabel.text = spell.notes;
    manaLabel.text = [NSString stringWithFormat:@"%@ MP", spell.mana];
    if ([self.user.magic integerValue] >= [spell.mana integerValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        nameLabel.textColor = [UIColor darkTextColor];
        detailLabel.textColor = [UIColor darkTextColor];
        manaLabel.textColor = [UIColor darkTextColor];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        nameLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textColor = [UIColor lightGrayColor];
        manaLabel.textColor = [UIColor lightGrayColor];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

@end
