//
//  HRPGInboxChatViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGInboxChatViewController.h"
#import "HRPGAppDelegate.h"
#import "InboxMessage.h"
#import "UIViewController+Markdown.h"
#import "HRPGChatTableViewCell.h"
#import "HRPGTopHeaderNavigationController.h"
#import "HRPGUserProfileViewController.h"
#import "HRPGFlagInformationOverlayView.h"
#import "KLCPopup.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"

@interface HRPGInboxChatViewController ()

@property User *user;
@property UITextView *sizeTextView;
@property NSMutableDictionary *attributes;
@property CGFloat viewWidth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@end

@implementation HRPGInboxChatViewController

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
    return UITableViewStylePlain;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sizeTextView = [[UITextView alloc] init];
    self.sizeTextView.textContainerInset = UIEdgeInsetsZero;
    self.sizeTextView.contentInset = UIEdgeInsetsZero;
    [self configureMarkdownAttributes];
    self.viewWidth = self.view.frame.size.width;

    self.user = [self.sharedManager getUser];
    
    UINib *nib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChatMessageCell"];
    
    [self setNavigationTitle];
    if (self.username == nil || [self.username length] == 0) {
        [self fetchMemberWithNetworkFallback:YES];
    }
    
    if (self.isPresentedModally) {
        [self.navigationItem setRightBarButtonItems:@[self.doneBarButton] animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItems:@[self.profileBarButton] animated:NO];
    }
}

- (void)setNavigationTitle {
    if (self.username) {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Write to %@", nil), self.username];
    } else {
        self.navigationItem.title = NSLocalizedString(@"Write Message", nil);
    }
}

- (void)fetchMemberWithNetworkFallback:(BOOL)fallback {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.userID]];
    
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results.count > 1) {
        User *member = results[0];
        self.username = member.username;
        [self setNavigationTitle];
    } else {
        if (fallback) {
            __weak HRPGInboxChatViewController *weakSelf = self;
            [self.sharedManager fetchMember:self.userID onSuccess:^{
                [weakSelf fetchMemberWithNetworkFallback:NO];
            } onError:nil];
        }
        
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self hrpgTopHeaderNavigationController]) {
        [[self hrpgTopHeaderNavigationController] scrollview:self.scrollView scrolledToPosition:0];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HRPGChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessageCell" forIndexPath:indexPath];
    cell.transform = self.tableView.transform;
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    if (!message.attributedText) {
        message.attributedText = [self renderMarkdown:message.text];
    }
    self.sizeTextView.attributedText = message.attributedText;
    
    CGSize suggestedSize =
    [self.sizeTextView sizeThatFits:CGSizeMake(self.viewWidth - 26, CGFLOAT_MAX)];
    
    CGFloat rowHeight = suggestedSize.height + 35;
    return rowHeight;
}

- (void)didPressRightButton:(id)sender {
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    InboxMessage *message = [self.managedObjectContext insertNewObjectForEntityForName:@"InboxMessage"];
    message.text = [self.textView.text copy];
    message.timestamp = [NSDate date];
    message.userID = self.userID;
    message.username = self.username;
    message.sent = [NSNumber numberWithBool:YES];
    message.sending = [NSNumber numberWithBool:YES];
    NSError *error;
    [self.managedObjectContext save:&error];
    [self.sharedManager privateMessage:message toUserWithID:self.userID onSuccess:nil onError:nil];
    
    [super didPressRightButton:sender];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InboxMessage"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"userID == %@", self.userID];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *timestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[ timestampDescriptor ];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use
        // this function in a shipping application, although it may be useful during development.
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
    
    
    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:rowAnimation];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:rowAnimation];
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

- (void)configureCell:(HRPGChatTableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    InboxMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    __weak HRPGInboxChatViewController *weakSelf = self;
    cell.profileAction = ^() {
        HRPGUserProfileViewController *profileViewController =
        [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        profileViewController.userID = message.userID;
        profileViewController.username = message.username;
        [weakSelf.navigationController pushViewController:profileViewController animated:YES];
    };
    
    cell.deleteAction = ^() {
        [weakSelf.sharedManager deletePrivateMessage:message onSuccess:nil onError:nil];
    };
    
    [cell configureForInboxMessage:message withUser:self.user];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        HRPGUserProfileViewController *userProfileViewController = segue.destinationViewController;
        userProfileViewController.userID = self.userID;
        userProfileViewController.username = self.username;
    }
    [super prepareForSegue:segue sender:sender];
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate =
        (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = self.sharedManager.getManagedObjectContext;
    }
    return _managedObjectContext;
}

@end
