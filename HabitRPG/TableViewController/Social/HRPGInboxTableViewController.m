//
//  HRPGInboxTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGInboxTableViewController.h"
#import "InboxMessage.h"
#import "HRPGInboxChatViewController.h"
#import "HRPGChoosePMRecipientViewController.h"
#import "Habitica-Swift.h"

@interface HRPGInboxTableViewController ()

@property NSArray<InboxMessage *> *inboxMessages;
@property NSString *recipientUserID;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.datasource markInboxSeen];
    [super viewDidAppear:animated];
}

-(NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"inbox"]) {
        return @{
                 @"text" :
                     NSLocalizedString(@"This is where you can read and reply to private messages! You can also message people from their profiles.", nil)
                 };
    }
    return nil;
}

#pragma mark - Table view data source

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    HRPGChoosePMRecipientViewController *recipientViewController = segue.sourceViewController;
    if (recipientViewController.userID) {
        self.recipientUserID = recipientViewController.userID;
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
            chatViewController.userID = self.recipientUserID;
        } else {
            UITableViewCell *cell = sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            id message = [self.datasource messageAtIndexPath:indexPath];
            chatViewController.userID = [message valueForKey:@"userID"];
            chatViewController.username =  [message valueForKey:@"username"];
        }
    }
}

@end
