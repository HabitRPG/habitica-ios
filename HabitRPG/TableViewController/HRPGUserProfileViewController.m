//
//  HRPGUserProfileViewController.m
//  Habitica
//
//  Created by Phillip on 13/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGUserProfileViewController.h"
#import "HRPGManager.h"
#import "User.h"
#import "HRPGLabeledProgressBar.h"
#import "UIColor+Habitica.h"
#import "UIViewController+Markdown.h"

@interface HRPGUserProfileViewController ()
@property(nonatomic, readonly, getter=getUser) User *user;
@property NSMutableDictionary *attributes;
@end

@implementation HRPGUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.sharedManager fetchMember:self.userID
        onSuccess:^() {

        }
        onError:^(){

        }];

    self.navigationItem.title = self.username;
    [self configureMarkdownAttributes];
}

- (void)refresh {
}

- (User *)getUser {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            return (User *)[self.fetchedResultsController
                objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.user) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname = @"Cell";
    if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0:
                cellname = @"ProfileCell";
                break;
            case 1:
                cellname = @"TextCell";
                break;
            case 2:
                cellname = @"SubtitleCell";
                break;
            case 3:
                cellname = @"SubtitleCell";
                break;
        }
    }
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0:
                [self configureCell:cell atIndexPath:indexPath];
                break;
            case 1: {
                UITextView *textView = (UITextView *)[cell viewWithTag:1];
                textView.attributedText = [self renderMarkdown:self.user.blurb];
                break;
            }
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Member Since", nil);
                cell.detailTextLabel.text =
                    [NSDateFormatter localizedStringFromDate:self.user.memberSince
                                                   dateStyle:NSDateFormatterMediumStyle
                                                   timeStyle:NSDateFormatterNoStyle];
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Last logged in", nil);
                cell.detailTextLabel.text =
                    [NSDateFormatter localizedStringFromDate:self.user.lastLogin
                                                   dateStyle:NSDateFormatterMediumStyle
                                                   timeStyle:NSDateFormatterNoStyle];
                break;
        }
    }
    [cell layoutSubviews];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 147;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        return [[self renderMarkdown:self.user.blurb]
                   boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin
                                context:nil]
                   .size.height +
               41;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }

    return [super tableView:tableView viewForHeaderInSection:section];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.userID]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [tableView reloadData];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [tableView reloadData];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            break;
        }
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath usForce:NO];
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
              usForce:(BOOL)force {
    if (indexPath.section == 0 && indexPath.item == 0) {
        User *user = (User *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        UILabel *levelLabel = (UILabel *)[cell viewWithTag:1];
        levelLabel.text =
            [NSString stringWithFormat:NSLocalizedString(@"Level %@", nil), user.level];

        HRPGLabeledProgressBar *healthLabel = (HRPGLabeledProgressBar *)[cell viewWithTag:2];
        healthLabel.color = [UIColor red100];
        healthLabel.icon = [UIImage imageNamed:@"icon_health"];
        healthLabel.type = NSLocalizedString(@"Health", nil);
        healthLabel.value = user.health;
        healthLabel.maxValue = [NSNumber numberWithInt:50];

        HRPGLabeledProgressBar *experienceLabel = (HRPGLabeledProgressBar *)[cell viewWithTag:3];
        experienceLabel.color = [UIColor yellow100];
        experienceLabel.icon = [UIImage imageNamed:@"icon_experience"];
        experienceLabel.type = NSLocalizedString(@"Experience", nil);
        experienceLabel.value = user.experience;
        experienceLabel.maxValue = user.nextLevel;

        HRPGLabeledProgressBar *magicLabel = (HRPGLabeledProgressBar *)[cell viewWithTag:4];

        if ([user.level integerValue] >= 10) {
            magicLabel.color = [UIColor blue100];
            magicLabel.icon = [UIImage imageNamed:@"icon_magic"];
            magicLabel.type = NSLocalizedString(@"Mana", nil);
            magicLabel.value = user.magic;
            magicLabel.maxValue = user.maxMagic;
            magicLabel.hidden = NO;
        } else {
            magicLabel.hidden = YES;
        }
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:8];
        [user setAvatarOnImageView:imageView useForce:force];
    }
}

@end
