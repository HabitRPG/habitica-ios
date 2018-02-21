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

@interface HRPGInboxChatViewController ()

@property User *user;
@property UITextView *sizeTextView;
@property CGFloat viewWidth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property NSIndexPath *expandedChatPath;
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
    self.sizeTextView.font = [CustomFontMetrics scaledSystemFontOfSize:15.0f compatibleWith:nil];
    self.viewWidth = self.view.frame.size.width;

    self.user = [[HRPGManager sharedManager] getUser];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (InboxMessage *message in self.fetchedResultsController.fetchedObjects) {
            if (!message.attributedText) {
                message.attributedText = [self renderMarkdown:message.text];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
        });
    });
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessageCell"];
    cell.transform = self.tableView.transform;
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (message.attributedText && message.attributedText.length > 0) {
        self.sizeTextView.attributedText = [message.attributedText attributedSubstringFromRange:NSMakeRange(0, message.attributedText.length-1)];
    } else {
        self.sizeTextView.text = message.text;
    }
    
    CGFloat horizontalPadding = 41;
    if ([message.sent boolValue]) {
        horizontalPadding += 56;
    }
    CGSize suggestedSize = [self.sizeTextView sizeThatFits:CGSizeMake(self.viewWidth - horizontalPadding, CGFLOAT_MAX)];
    
    CGFloat rowHeight = suggestedSize.height + 72;
    if (self.expandedChatPath != nil && self.expandedChatPath.item == indexPath.item) {
        rowHeight += 36;
    }
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
    [[HRPGManager sharedManager] privateMessage:message toUserWithID:self.userID onSuccess:nil onError:nil];
    
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

- (void)configureCell:(ChatTableViewCell *)cell
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
    cell.copyAction = ^{
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:message.text];
    };
    cell.deleteAction = ^() {
        [[HRPGManager sharedManager] deletePrivateMessage:message onSuccess:nil onError:nil];
    };
    cell.expandAction = ^{
        [self expandSelectedCell:indexPath];
    };
    
    [cell configureWithInboxMessage:message previousMessage:[self itemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] nextMessage:[self itemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]] user:self.user isExpanded:[self.expandedChatPath isEqual:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        HRPGUserProfileViewController *userProfileViewController = segue.destinationViewController;
        userProfileViewController.userID = self.userID;
        userProfileViewController.username = self.username;
    }
    [super prepareForSegue:segue sender:sender];
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
    }
    return _managedObjectContext;
}

- (void)expandSelectedCell:(NSIndexPath *)indexPath {
    NSIndexPath *expandedPath = self.expandedChatPath;
    if ([self.tableView numberOfRowsInSection:0] < expandedPath.item) {
        expandedPath = nil;
    }
    self.expandedChatPath = indexPath;
    if (expandedPath == nil || indexPath.item == expandedPath.item) {
        CheckedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.isExpanded = !cell.isExpanded;
        if (!cell.isExpanded) {
            self.expandedChatPath = nil;
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    } else {
        CheckedTableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:expandedPath];
        CheckedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView beginUpdates];
        cell.isExpanded = YES;
        oldCell.isExpanded = NO;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath, expandedPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (InboxMessage *_Nullable)itemAtIndexPath:(NSIndexPath *)indexPath {
    InboxMessage *item  = nil;
    if ([[self.fetchedResultsController sections] count] > [indexPath section]){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
        if ([sectionInfo numberOfObjects] > [indexPath row]){
            item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    return item;
}

@end
