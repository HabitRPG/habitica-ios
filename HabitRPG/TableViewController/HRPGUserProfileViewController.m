//
//  HRPGUserProfileViewController.m
//  RabbitRPG
//
//  Created by Phillip on 13/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGUserProfileViewController.h"
#import "HRPGManager.h"
#import "User.h"
#import "NSMutableAttributedString_GHFMarkdown.h"

@interface HRPGUserProfileViewController ()
@property (nonatomic, readonly, getter=getUser) User *user;
@end

@implementation HRPGUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    [self.sharedManager fetchMember:self.userID onSuccess:^() {
        
    }onError:^() {
        
    }];
    
    self.navigationItem.title = self.username;
}

- (void)refresh {

}

- (User*) getUser {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            return (User *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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
            return nil;
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname = @"Cell";
    if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0:
                cellname = @"ProfileCell";
                break;
            case 1:
                break;
            case 2:
                cellname = @"SubtitleCell";
                break;
            case 3:
                cellname = @"SubtitleCell";
                break;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0:
                [self configureCell:cell atIndexPath:indexPath];
                break;
            case 1: {
                NSMutableAttributedString *attributedText = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:self.user.blurb];
                [attributedText ghf_applyAttributes:self.markdownAttributes];
                cell.textLabel.attributedText = attributedText;
                break;
            }
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Member Since", nil);
                cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.user.memberSince
                                                                           dateStyle:NSDateFormatterMediumStyle
                                                                           timeStyle:NSDateFormatterNoStyle];                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Last logged in", nil);
                cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.user.lastLogin
                                                                           dateStyle:NSDateFormatterMediumStyle
                                                                           timeStyle:NSDateFormatterNoStyle];
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 147;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        NSMutableAttributedString *attributedText = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:self.user.blurb];
        [attributedText ghf_applyAttributes:self.markdownAttributes];
        return [attributedText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                          context:nil].size.height + 41;
    } else {
        return 44;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.userID]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *idDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = @[idDescriptor];
    
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
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
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

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath usForce:NO];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath usForce:(BOOL)force {
    if (indexPath.section == 0 && indexPath.item == 0) {
        User *user = (User *) [self.fetchedResultsController objectAtIndexPath:indexPath];
        UILabel *levelLabel = (UILabel *) [cell viewWithTag:1];
        levelLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Level %@", nil), user.level];
        
        UILabel *healthLabel = (UILabel *) [cell viewWithTag:2];
        healthLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long) [user.health integerValue], 50];
        UIProgressView *healthProgress = (UIProgressView *) [cell viewWithTag:3];
        healthProgress.progress = ([user.health floatValue] / 50.0);
        
        UILabel *experienceLabel = (UILabel *) [cell viewWithTag:4];
        experienceLabel.text = [NSString stringWithFormat:@"%ld/%@", (long) [user.experience integerValue], user.nextLevel];
        UIProgressView *experienceProgress = (UIProgressView *) [cell viewWithTag:5];
        experienceProgress.progress = ([user.experience floatValue] / [user.nextLevel floatValue]);
        
        UILabel *magicLabel = (UILabel *) [cell viewWithTag:6];
        
        UIProgressView *magicProgress = (UIProgressView *) [cell viewWithTag:7];
        if ([user.level integerValue] >= 10) {
            magicLabel.text = [NSString stringWithFormat:@"%ld/%@", (long) [user.magic integerValue], user.maxMagic];
            magicProgress.progress = ([user.magic floatValue] / [user.maxMagic floatValue]);
            magicLabel.hidden = NO;
            magicProgress.hidden = NO;
        } else {
            magicLabel.hidden = YES;
            magicProgress.hidden = YES;
        }
        UIImageView *imageView = (UIImageView *) [cell viewWithTag:8];
        [user setAvatarOnImageView:imageView useForce:force];
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.000];
    }
}


@end
