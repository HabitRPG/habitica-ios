//
//  HRPGSpellUserTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/10/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGSpellUserTableViewController.h"
#import "HRPGCoreDataDataSource.h"
#import "User.h"

@interface HRPGSpellUserTableViewController ()

@property HRPGCoreDataDataSource *dataSource;

@end

@implementation HRPGSpellUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

- (void)setupTableView {
        __weak HRPGSpellUserTableViewController *weakSelf = self;
        TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, User *user, NSIndexPath *indexPath) {
            UITextView *nameTextView = [cell viewWithTag:1];
            UIView *avatarView = [cell viewWithTag:2];
            nameTextView.text = user.username;
            [user setAvatarSubview:avatarView showsBackground:NO showsMount:NO showsPet:NO];
        };
        FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
            NSString *partyID = [[HRPGManager sharedManager] getUser].partyID;
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"partyID == %@", partyID]];
            NSSortDescriptor *levelSortDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
            NSArray *sortDescriptors = @[ levelSortDescriptor ];
            [fetchRequest setSortDescriptors:sortDescriptors];
        };
        self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                           entityName:@"User"
                                                                       cellIdentifier:@"Cell"
                                                                   configureCellBlock:configureCell
                                                                    fetchRequestBlock:configureFetchRequest
                                                                        asDelegateFor:self.tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.dataSource itemAtIndexPath:indexPath];
    
    if (user) {
        self.userID = user.id;
    }
    [self performSegueWithIdentifier:@"CastUserSpellSegue" sender:self];
}

@end
