//
//  HRPGInboxTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGInboxTableViewController.h"
#import "HRPGInboxChatViewController.h"
#import "HRPGChoosePMRecipientViewController.h"
#import "Habitica-Swift.h"

@interface HRPGInboxTableViewController ()

@property NSString *recipientUsername;
@property id<InboxOverviewDataSourceProtocol> datasource;

@end

@implementation HRPGInboxTableViewController

- (void)viewDidLoad {
    self.tutorialIdentifier = @"inbox";
    [super viewDidLoad];
    self.datasource = [InboxOverviewDataSourceInstantiator instantiate];
    self.datasource.tableView = self.tableView;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.tableView.backgroundColor = ObjcThemeWrapper.contentBackgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.datasource markInboxSeen];
    [super viewDidAppear:animated];
}

- (void)refresh {
    __weak HRPGInboxTableViewController *weakSelf = self;
    [self.datasource refreshWithCompleted:^{
        [weakSelf.refreshControl endRefreshing];
    }];
}

-(NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"inbox"]) {
        return @{
                 @"text" :
                     objcL10n.tutorialInbox
                 };
    }
    return nil;
}

#pragma mark - Table view data source

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGChoosePMRecipientViewController *recipientViewController = segue.sourceViewController;
    if (recipientViewController.username) {
        self.recipientUsername = recipientViewController.username;
        [self performSelector:@selector(performChatSegue) withObject:nil afterDelay:2];

    }
}

- (void)performChatSegue {
    [self performSegueWithIdentifier:@"ChatSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChatSegue"]) {
        HRPGInboxChatViewController *chatViewController = (HRPGInboxChatViewController *)segue.destinationViewController;
        if (sender == self) {
            chatViewController.username = self.recipientUsername;
        } else {
            UITableViewCell *cell = sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            id message = [self.datasource messageAtIndexPath:indexPath];
            chatViewController.userID = [message valueForKey:@"userID"];
            chatViewController.displayName =  [message valueForKey:@"displayName"];
        }
    }
}

@end
