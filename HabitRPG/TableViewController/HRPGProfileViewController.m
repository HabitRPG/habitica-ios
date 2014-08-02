//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGProfileViewController.h"
#import "HRPGAppDelegate.h"
#import "Group.h"
#import "VTAcknowledgementsViewController.h"
#import <PDKeychainBindings.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import <UserVoice.h>

@interface HRPGProfileViewController ()
@property HRPGManager *sharedManager;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation HRPGProfileViewController
@synthesize managedObjectContext;
@dynamic sharedManager;
NSString *username;
NSInteger userLevel;
NSString *currentUserID;
PDKeychainBindings *keyChain;
NIKFontAwesomeIconFactory *iconFactory;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![currentUserID isEqualToString:[keyChain stringForKey:@"id"]]) {
        currentUserID = [keyChain stringForKey:@"id"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", currentUserID];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        User *user = (User *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        username = user.username;
        userLevel = [user.level integerValue];
        [self.tableView reloadData];
    }
    self.navigationItem.title = username;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            User *user = (User *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            username = user.username;
            userLevel = [user.level integerValue];
        }
    }
    if (username == nil) {
        [self refresh];
    }

    iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    iconFactory.square = YES;
    iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
    
    UILabel* footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    footerView.text = [NSString stringWithFormat:NSLocalizedString(@"Hey! You are awesome!\nVersion %@", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    footerView.textColor = [UIColor lightGrayColor];
    footerView.textAlignment = NSTextAlignmentCenter;
    footerView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    footerView.numberOfLines = 0;
    self.tableView.tableFooterView = footerView;
    [self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, -70, 0))];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPartyData:) name:@"partyUpdated"  object:nil];
}

- (void)refresh {
    [self.sharedManager fetchUser:^() {
        [self.refreshControl endRefreshing];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    }                     onError:^() {
        [self.refreshControl endRefreshing];
    }];
}


- (void)reloadPartyData:(id)sender {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (userLevel <= 10) {
                return 1;
            } else {
                return 2;
            }
        case 1:
            return 2;
        case 2:
            return 4;
        case 3:
            return 3;
        default:
            return 0;
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
            return NSLocalizedString(@"Social", nil);
        case 2:
            return NSLocalizedString(@"Inventory", nil);
        case 3:
            return NSLocalizedString(@"About", nil);
        default:
            return @"";
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    iconFactory.colors = @[[UIColor darkGrayColor]];
    iconFactory.size = 16.f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37.5)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 290, 17)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor darkGrayColor];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 14, 16, 16)];
    iconView.contentMode = UIViewContentModeCenter;
    [view addSubview:label];
    [view addSubview:iconView];
    
    label.text = [[self tableView:tableView titleForHeaderInSection:section] uppercaseString];
    if (section == 1) {
        iconView.image = [iconFactory createImageForIcon:NIKFontAwesomeIconUsers];
    } else if (section == 2) {
        iconView.image = [iconFactory createImageForIcon:NIKFontAwesomeIconSuitcase];
    } else if (section == 3) {
        iconView.image = [iconFactory createImageForIcon:NIKFontAwesomeIconQuestionCircle];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 147;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 1) {
        [self performSegueWithIdentifier:@"SpellSegue" sender:self];
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        [self performSegueWithIdentifier:@"TavernSegue" sender:self];
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        [self performSegueWithIdentifier:@"PartySegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 0) {
        [self performSegueWithIdentifier:@"EquipmentSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 1) {
        [self performSegueWithIdentifier:@"ItemSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 2) {
        [self performSegueWithIdentifier:@"PetSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 3) {
        [self performSegueWithIdentifier:@"MountSegue" sender:self];
    } else if (indexPath.section == 3 && indexPath.item == 0) {
        [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
    } else if (indexPath.section == 3 && indexPath.item == 1) {
        VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        viewController.headerText = NSLocalizedString(@"We love open source software.", nil); // optional
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == 3 && indexPath.item == 2) {
        [UserVoice presentUserVoiceInterfaceForParentViewController:self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (username == nil) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyProfileCell" forIndexPath:indexPath];
            return cell;
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath usForce:NO];
        return cell;
    } else {
        NSString *title = nil;
        NSString *cellName = @"Cell";
        BOOL showIndicator = NO;
        if (indexPath.section == 0 && indexPath.item == 1) {
            title = NSLocalizedString(@"Spells", nil);
        } else if (indexPath.section == 1 && indexPath.item == 0) {
            title = NSLocalizedString(@"Tavern", nil);
        } else if (indexPath.section == 1 && indexPath.item == 1) {
            title = NSLocalizedString(@"Party", nil);
            User *user = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            if ([user.party.unreadMessages boolValue]) {
                showIndicator = YES;
            }
        } else if (indexPath.section == 2 && indexPath.item == 0) {
            title = NSLocalizedString(@"Equipment", nil);
        } else if (indexPath.section == 2 && indexPath.item == 1) {
            title = NSLocalizedString(@"Items", nil);
        } else if (indexPath.section == 2 && indexPath.item == 2) {
            title = NSLocalizedString(@"Pets", nil);
        } else if (indexPath.section == 2 && indexPath.item == 3) {
            title = NSLocalizedString(@"Mounts", nil);
        } else if (indexPath.section == 3 && indexPath.item == 0) {
            title = NSLocalizedString(@"Settings", nil);
        } else if (indexPath.section == 3 && indexPath.item == 1) {
            title = NSLocalizedString(@"Acknowledgements", nil);
        } else if (indexPath.section == 3 && indexPath.item == 2) {
            title = NSLocalizedString(@"Send Feedback", nil);
        }

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        label.text = title;
        UIImageView *indicatorView = (UIImageView *) [cell viewWithTag:2];
        indicatorView.hidden = !showIndicator;
        if (showIndicator) {
            iconFactory.colors = @[[UIColor colorWithRed:0.372 green:0.603 blue:0.014 alpha:1.000]];
            iconFactory.size = 13.0f;
            indicatorView.image = [iconFactory createImageForIcon:NIKFontAwesomeIconCircle];
        }
        return cell;
    }
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

    keyChain = [PDKeychainBindings sharedKeychainBindings];
    currentUserID = [keyChain stringForKey:@"id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", currentUserID]];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];


    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"username" cacheName:nil];
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
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert: {
            User *user = (User *) [self.fetchedResultsController objectAtIndexPath:newIndexPath];
            username = user.username;
            [tableView reloadData];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath usForce:YES];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            username = nil;
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
    User *user = (User *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *levelLabel = (UILabel *) [cell viewWithTag:1];
    levelLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Level %@", nil), user.level];

    UILabel *healthLabel = (UILabel *) [cell viewWithTag:2];
    healthLabel.text = [NSString stringWithFormat:@"%ld/%@", (long) [user.health integerValue], user.maxHealth];
    UIProgressView *healthProgress = (UIProgressView *) [cell viewWithTag:3];
    healthProgress.progress = ([user.health floatValue] / [user.maxHealth floatValue]);

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


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^(){

    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
