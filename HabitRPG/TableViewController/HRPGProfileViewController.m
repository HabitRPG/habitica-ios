//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGProfileViewController.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGProfileViewController ()

@property(nonatomic) User *user;
@property(nonatomic) MenuNavigationBarView *navbarView;

@end

@implementation HRPGProfileViewController
NSString *username;
NSInteger userLevel;
NSString *currentUserID;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    self.navbarView = [[MenuNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 72)];
    __weak HRPGProfileViewController *weakSelf = self;
    [self.navbarView setMessagesAction:^{
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Social" bundle:nil];
        UIViewController *inboxViewController =
        [secondStoryBoard instantiateViewControllerWithIdentifier:@"InboxViewController"];
        [weakSelf.navigationController pushViewController:inboxViewController animated:YES];
    }];
    [self.navbarView setSettingsAction:^{
        [weakSelf performSegueWithIdentifier:@"SettingsSegue" sender:weakSelf];
    }];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor purple400];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    if (self.user) {
        [self configure:self.user];
    } else {
        // User does not exist in database. Fetch it.
        [self refresh];
    }
    
    UILabel *footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
    footerView.text = [NSString
                       stringWithFormat:NSLocalizedString(@"Hey! You are awesome!\nVersion %@ (%@)", nil),
                       [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                       [[NSBundle mainBundle]
                        objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    footerView.textColor = [UIColor lightGrayColor];
    footerView.textAlignment = NSTextAlignmentCenter;
    footerView.font = [CustomFontMetrics scaledSystemFontOfSize:12 compatibleWith:nil];
    footerView.numberOfLines = 0;
    self.tableView.tableFooterView = footerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPartyData:)
                                                 name:@"partyUpdated"
                                               object:nil];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    self.topHeaderNavigationController.shouldHideTopHeader = NO;
    [self.topHeaderNavigationController setAlternativeHeaderView:self.navbarView];
    [self.topHeaderNavigationController showHeaderWithAnimated:NO];
    
    [super viewWillAppear:animated];
    
    UINavigationController<TopHeaderNavigationControllerProtocol> *navigationController =
        (UINavigationController<TopHeaderNavigationControllerProtocol> *)self.navigationController;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(navigationController.contentInset, 0, 0, 0);
    [self.tableView setContentInset:(UIEdgeInsetsMake(navigationController.contentInset, 0, -150, 0))];
    
    self.topHeaderNavigationController.navbarVisibleColor = [UIColor purple300];
    self.topHeaderNavigationController.hideNavbar = YES;
    if (![currentUserID isEqualToString:[HRPGManager.sharedManager getUser].id]) {
        // user has changed. Reload data.
        currentUserID = [HRPGManager.sharedManager getUser].id;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", currentUserID];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (self.user) {
            [self configure:self.user];
        }
        [self.tableView reloadData];
    }
    self.navigationItem.title = NSLocalizedString(@"Menu", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.topHeaderNavigationController stopFollowingScrollView];
    
    if (self.topHeaderNavigationController.shouldHideTopHeader) {
        self.topHeaderNavigationController.shouldHideTopHeader = NO;
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.topHeaderNavigationController removeAlternativeHeaderView];
    [super viewWillDisappear:animated];
}

- (void)refresh {
    [[HRPGManager sharedManager] fetchUser:^() {
        [self.refreshControl endRefreshing];
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:1 inSection:1] ]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
        onError:^() {
            [self.refreshControl endRefreshing];
        }];
}

- (void)reloadPartyData:(id)sender {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:1 inSection:1] ]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            // Below level 10 users don't have spells or attribute points
            if ([self.user.level integerValue] < 10) {
                return 0;
            } else if ([self.user.preferences.disableClass boolValue]) {
                return 1;
            } else {
                return 2;
            }
        case 1:
            return 4;
        case 2:
            return 7;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    CGRect labelFrame = CGRectMake(30, 14, 290, 17);
    CGRect iconFrame = CGRectMake(9, 14, 16, 16);
    
    if ([UIApplication instancesRespondToSelector:@selector(userInterfaceLayoutDirection)]) {
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            labelFrame = CGRectMake(9, 14, self.viewWidth-39, 17);
            iconFrame = CGRectMake(self.viewWidth-25, 14, 16, 16);
        }
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 37.5)];
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor darkGrayColor];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeCenter;
    [view addSubview:label];
    [view addSubview:iconView];

    label.text = [[self tableView:tableView titleForHeaderInSection:section] uppercaseString];
    iconView.tintColor = [UIColor darkGrayColor];
    if (section == 1) {
        iconView.image = [UIImage imageNamed:@"icon_social"];
    } else if (section == 2) {
        iconView.image = [UIImage imageNamed:@"icon_inventory"];
    } else if (section == 3) {
        iconView.image = [UIImage imageNamed:@"icon_help"];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (![self.user.flags.classSelected boolValue] &&
            ![self.user.preferences.disableClass boolValue]) {
            [self performSegueWithIdentifier:@"SelectClassSegue" sender:self];
        } else if ([self.user.preferences.disableClass boolValue]) {
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"User" bundle:nil];
            UIViewController *tavernViewController =
            [secondStoryBoard instantiateViewControllerWithIdentifier:@"AttributePointsViewController"];
            [self.navigationController pushViewController:tavernViewController animated:YES];
        } else {
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"User" bundle:nil];
            UIViewController *tavernViewController =
            [secondStoryBoard instantiateViewControllerWithIdentifier:@"SpellsViewController"];
            [self.navigationController pushViewController:tavernViewController animated:YES];
        }
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"User" bundle:nil];
        UIViewController *tavernViewController =
        [secondStoryBoard instantiateViewControllerWithIdentifier:@"AttributePointsViewController"];
        [self.navigationController pushViewController:tavernViewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Social" bundle:nil];
        UIViewController *tavernViewController =
            [secondStoryBoard instantiateViewControllerWithIdentifier:@"TavernViewController"];
        [self.navigationController pushViewController:tavernViewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Social" bundle:nil];
        UIViewController *partyViewController =
            [secondStoryBoard instantiateViewControllerWithIdentifier:@"PartyViewController"];
        [self.navigationController pushViewController:partyViewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.item == 2) {
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Social" bundle:nil];
        UIViewController *guildsViewController = [secondStoryBoard
                                                  instantiateViewControllerWithIdentifier:@"GuildsOverviewViewController"];
        [self.navigationController pushViewController:guildsViewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.item == 3) {
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Social" bundle:nil];
        UIViewController *challengeViewController = [secondStoryBoard
                                                  instantiateViewControllerWithIdentifier:@"ChallengeTableViewController"];
        [self.navigationController pushViewController:challengeViewController animated:YES];
    } else if (indexPath.section == 2 && indexPath.item == 0) {
        self.topHeaderNavigationController.shouldHideTopHeader = YES;
        [self performSegueWithIdentifier:@"ShopsSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 1) {
        [self performSegueWithIdentifier:@"CustomizationSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 2) {
        [self performSegueWithIdentifier:@"EquipmentSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 3) {
        [self performSegueWithIdentifier:@"ItemSegue" sender:self];
    } else if (indexPath.section == 2 && indexPath.item == 4) {
        if ([self.user.flags.itemsEnabled boolValue]) {
            [self performSegueWithIdentifier:@"PetSegue" sender:self];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else if (indexPath.section == 2 && indexPath.item == 5) {
        if ([self.user.flags.itemsEnabled boolValue]) {
            [self performSegueWithIdentifier:@"MountSegue" sender:self];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else if (indexPath.section == 2 && indexPath.item == 6) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navigationController =
        [storyboard instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
        UIViewController *viewController = self;
        if (!viewController.isViewLoaded || !viewController.view.window) {
            viewController = viewController.presentedViewController;
        }
        [viewController presentViewController:navigationController animated:YES completion:nil];
    } else if (indexPath.section == 3 && indexPath.item == 0) {
        [self performSegueWithIdentifier:@"NewsSegue" sender:self];
    } else if (indexPath.section == 3 && indexPath.item == 1) {
        [self performSegueWithIdentifier:@"FAQSegue" sender:self];
    } else if (indexPath.section == 3 && indexPath.item == 2) {
        [self performSegueWithIdentifier:@"AboutSegue" sender:self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = nil;
    NSString *accessibilityLabel = nil;
    NSString *cellName = @"Cell";
    BOOL showIndicator = NO;
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (![self.user.flags.classSelected boolValue] &&
            ![self.user.preferences.disableClass boolValue]) {
            title = NSLocalizedString(@"Select Class", nil);
        } else if ([self.user.preferences.disableClass boolValue]) {
            title = NSLocalizedString(@"Stats", nil);
        } else {
            if ([self.user.hclass isEqualToString:@"wizard"] ||
                [self.user.hclass isEqualToString:@"healer"]) {
                title = NSLocalizedString(@"Cast Spells", nil);
            } else {
                title = NSLocalizedString(@"Use Skills", nil);
            }
        }
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        title = NSLocalizedString(@"Stats", nil);
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        title = NSLocalizedString(@"Tavern", nil);
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        title = NSLocalizedString(@"Party", nil);
        accessibilityLabel = title;
        User *user = self.user;
        if (user) {
            if ([user.party.unreadMessages boolValue]) {
                showIndicator = YES;
            }
        }
    } else if (indexPath.section == 1 && indexPath.item == 2) {
        title = NSLocalizedString(@"Guilds", nil);
    } else if (indexPath.section == 1 && indexPath.item == 3) {
        title = NSLocalizedString(@"Challenges", nil);
    } else if (indexPath.section == 2 && indexPath.item == 0) {
        title = NSLocalizedString(@"Shops", nil);
    } else if (indexPath.section == 2 && indexPath.item == 1) {
        title = NSLocalizedString(@"Customize Avatar", nil);
    } else if (indexPath.section == 2 && indexPath.item == 2) {
        title = NSLocalizedString(@"Equipment", nil);
    } else if (indexPath.section == 2 && indexPath.item == 3) {
        title = NSLocalizedString(@"Items", nil);
    } else if (indexPath.section == 2 && indexPath.item == 4) {
        title = NSLocalizedString(@"Pets", nil);
        if (![self.user.flags.itemsEnabled boolValue]) {
            cellName = @"LockedCell";
        }
    } else if (indexPath.section == 2 && indexPath.item == 5) {
        title = NSLocalizedString(@"Mounts", nil);
        if (![self.user.flags.itemsEnabled boolValue]) {
            cellName = @"LockedCell";
        }
    } else if (indexPath.section == 2 && indexPath.item == 6) {
        title = NSLocalizedString(@"Gems & Subscriptions", nil);
    } else if (indexPath.section == 3 && indexPath.item == 0) {
        title = NSLocalizedString(@"News", nil);
        User *user = self.user;
        if (user) {
            if ([user.flags.habitNewStuff boolValue]) {
                showIndicator = YES;
            }
        }
    } else if (indexPath.section == 3 && indexPath.item == 1) {
        title = NSLocalizedString(@"Help & FAQ", nil);
    } else if (indexPath.section == 3 && indexPath.item == 2) {
        title = NSLocalizedString(@"About", nil);
    }

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    if (accessibilityLabel) {
        cell.accessibilityLabel = accessibilityLabel;
    }
    UILabel *label = [cell viewWithTag:1];
    label.text = title;
    label.font = [CustomFontMetrics scaledSystemFontOfSize:17 compatibleWith:nil];
    NSOperatingSystemVersion ios10_0_0 = (NSOperatingSystemVersion){10, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_0_0]) {
        label.adjustsFontForContentSizeCategory = YES;
    }
    UIImageView *indicatorView = [cell viewWithTag:2];
    indicatorView.hidden = !showIndicator;
    indicatorView.layer.cornerRadius = indicatorView.frame.size.height / 2;
    return cell;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", [HRPGManager.sharedManager getUser].id]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[ sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:@"username"
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

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            self.user = (User *)[self.fetchedResultsController objectAtIndexPath:newIndexPath];
            [self configure:self.user];
            [tableView reloadData];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            self.user = (User *)[self.fetchedResultsController objectAtIndexPath:newIndexPath];
            [self configure:self.user];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:0 inSection:3] ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self configure:nil];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (User *)user {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            _user = [self.fetchedResultsController
                objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }

    return _user;
}

- (void)configure:(User *)user {
    username = user.username;
    userLevel = [user.level integerValue];
    if (user != nil) {
        [self.navbarView configureWithUser:user];
    }
}

@end
