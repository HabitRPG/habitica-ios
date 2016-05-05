//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGPartyMembersViewController.h"
#import "HRPGInviteMembersViewController.h"
#import "HRPGLabeledProgressBar.h"
#import "HRPGUserProfileViewController.h"
#import "UIColor+Habitica.h"
#import "UIViewController+TutorialSteps.h"

@interface HRPGPartyMembersViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property NSIndexPath *openedIndexPath;
@property NSString *sortKey;
@property BOOL sortAscending;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate;
@end

@implementation HRPGPartyMembersViewController

- (void)viewDidLoad {
    NSString *orderSetting = [self.sharedManager getUser].partyOrder;
    if ([orderSetting isEqualToString:@"level"]) {
        self.sortKey = @"level";
        self.sortAscending = NO;
    } else if ([orderSetting isEqualToString:@"pets"]) {
        self.sortKey = @"petCount";
        self.sortAscending = NO;
    } else if ([orderSetting isEqualToString:@"random"]) {
        self.sortKey = @"username";
        self.sortAscending = YES;
    } else {
        self.sortKey = @"partyPosition";
        self.sortAscending = NO;
    }

    [super viewDidLoad];

    [self setUpInvitationButton];

    [self.sharedManager fetchGroupMembers:[self.sharedManager getUser].partyID lastID:nil withPublicFields:YES fetchAll:YES onSuccess:nil onError:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate =
        [NSPredicate predicateWithFormat:@"partyID == %@", [self.sharedManager getUser].partyID];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *idDescriptor =
        [[NSSortDescriptor alloc] initWithKey:self.sortKey ascending:self.sortAscending];
    NSArray *sortDescriptors = @[ idDescriptor ];

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
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath
                  withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = [cell viewWithTag:1];
    textLabel.text = user.username;
    UIImageView *avatarView = [cell viewWithTag:2];
    avatarView.image = nil;
    [user setAvatarOnImageView:avatarView withPetMount:NO onlyHead:NO useForce:NO];

    HRPGLabeledProgressBar *healthLabel = [cell viewWithTag:3];
    healthLabel.color = [UIColor red100];
    healthLabel.icon = [UIImage imageNamed:@"icon_health"];
    healthLabel.value = user.health;
    healthLabel.maxValue = @50;

    UILabel *levelLabel = [cell viewWithTag:5];
    levelLabel.text = [NSString stringWithFormat:@"LVL %@", user.level];
    UILabel *classLabel = [cell viewWithTag:6];
    classLabel.text = user.hclass;
    [classLabel.layer setCornerRadius:5.0f];
    classLabel.backgroundColor = [user classColor];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        HRPGUserProfileViewController *userProfileViewController = segue.destinationViewController;
        userProfileViewController.userID = user.id;
        userProfileViewController.username = user.username;
    }
    [super prepareForSegue:segue sender:sender];
}

- (void)setUpInvitationButton {
    if (self.isLeader) {
        UIBarButtonItem *barButton =
            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Invite", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(openInvitationForm)];
        self.navigationItem.rightBarButtonItem = barButton;
    }
}

- (void)openInvitationForm {
    [self performSegueWithIdentifier:@"InvitationSegue" sender:self];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGInviteMembersViewController *formViewController = segue.sourceViewController;
    [self.sharedManager inviteMembers:formViewController.members
        withInvitationType:formViewController.invitationType
        toGroupWithID:self.partyID
        onSuccess:^() {

        }
        onError:^(){

        }];
}

@end
