//
//  HRPGInboxChatViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGInboxChatViewController.h"
#import "InboxMessage.h"
#import "UIViewController+Markdown.h"
#import "HRPGUserProfileViewController.h"
#import "HRPGFlagInformationOverlayView.h"
#import "KLCPopup.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"
#import "NSString+Emoji.h"

@interface HRPGInboxChatViewController ()

@property CGFloat viewWidth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property id<InboxMessagesDataSourceProtocol> datasource;
@end

@implementation HRPGInboxChatViewController

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
    return UITableViewStylePlain;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datasource = [InboxMessagesDataSourceInstantiator instantiateWithOtherUserID: self.userID];
    self.datasource.tableView = self.tableView;
    
    self.viewWidth = self.view.frame.size.width;
    
    UINib *nib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChatMessageCell"];
    
    [self setNavigationTitle];
    if (self.username == nil || [self.username length] == 0) {
        [User fetchUserWithId:self.userID completionBlock:^(User *member) {
            self.username = member.username;
            [self setNavigationTitle];
        }];
    }
    
    if (self.isPresentedModally) {
        [self.navigationItem setRightBarButtonItems:@[self.doneBarButton] animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItems:@[self.profileBarButton] animated:NO];
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.backgroundColor = [UIColor gray700];
}

- (void)setNavigationTitle {
    if (self.username) {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Write to %@", nil), self.username];
    } else {
        self.navigationItem.title = NSLocalizedString(@"Write Message", nil);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self hrpgTopHeaderNavigationController]) {
        [[self hrpgTopHeaderNavigationController] scrollView:self.scrollView scrolledToPosition:0];
    }
}

- (void)didPressRightButton:(id)sender {
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    [self.datasource sendMessageWithMessageText:self.textView.text];
    [super didPressRightButton:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        HRPGUserProfileViewController *userProfileViewController = segue.destinationViewController;
        userProfileViewController.userID = self.userID;
        userProfileViewController.username = self.username;
    }
    [super prepareForSegue:segue sender:sender];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = true;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScrolling = false;
    [super scrollViewDidEndDecelerating:scrollView];
}

@end
