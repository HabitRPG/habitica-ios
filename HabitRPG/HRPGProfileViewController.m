//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGProfileViewController.h"
#import "HRPGAppDelegate.h"
#import "Task.h"
#import "User.h"
#import <PDKeychainBindings.h>

@interface HRPGProfileViewController ()
@property HRPGManager *sharedManager;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation HRPGProfileViewController
@synthesize managedObjectContext;
NSString *username;


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
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    _sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = _sharedManager.getManagedObjectContext;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] > 0) {
            User *user = (User*)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            username = user.username;
        }
    }
    if (username == nil) {
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh {
    [_sharedManager fetchUser:^ () {
        [self.refreshControl endRefreshing];
    } onError:^ () {
        [self.refreshControl endRefreshing];
        [_sharedManager displayNetworkError];
    }];
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
            return 1;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return username;
            break;
        case 1:
            return NSLocalizedString(@"Social", nil);
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 150;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.item == 0) {
        [self performSegueWithIdentifier: @"PartySegue" sender: self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (username == nil) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyProfileCell" forIndexPath:indexPath];
            return cell;
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        NSString *title = nil;
        if (indexPath.section == 1 && indexPath.item == 0) {
            title = NSLocalizedString(@"Party", nil);
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        label.text = title;
        return cell;
    }
}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", [keyChain stringForKey:@"id"]]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"username" cacheName:@"profile"];
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


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            User *user = (User*)[self.fetchedResultsController objectAtIndexPath:newIndexPath];
            username = user.username;
            [tableView reloadData];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    User *user = (User*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *levelLabel = (UILabel*)[cell viewWithTag:1];
    levelLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LVL %@", nil), user.level];
    
    UILabel *healthLabel = (UILabel*)[cell viewWithTag:2];
    healthLabel.text = [NSString stringWithFormat:@"%ld/%@", (long)[user.health integerValue], user.maxHealth];
    UIProgressView *healthProgress = (UIProgressView*)[cell viewWithTag:3];
    healthProgress.progress = ([user.health floatValue] / [user.maxHealth floatValue]);
    
    UILabel *experienceLabel = (UILabel*)[cell viewWithTag:4];
    experienceLabel.text = [NSString stringWithFormat:@"%@/%@", user.experience, user.nextLevel];
    UIProgressView *experienceProgress = (UIProgressView*)[cell viewWithTag:5];
    experienceProgress.progress = ([user.experience floatValue] / [user.nextLevel floatValue]);
    
    UILabel *magicLabel = (UILabel*)[cell viewWithTag:6];
    magicLabel.text = [NSString stringWithFormat:@"%@/%@", user.magic, user.maxMagic];
    UIProgressView *magicProgress = (UIProgressView*)[cell viewWithTag:7];
    magicProgress.progress = ([user.magic floatValue] / [user.maxMagic floatValue]);
    
    
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
