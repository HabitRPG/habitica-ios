//
//  HRPGFAQTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFAQTableViewController.h"
#import "FAQ.h"
#import "HRPGFAQDetailViewController.h"
#import "TutorialSteps.h"
#import "HRPGCoreDataDataSource.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGFAQTableViewController ()

@property(nonatomic, strong) UISearchBar *searchBar;
@property NSString *searchText;
@property(nonatomic) HRPGCoreDataDataSource *dataSource;
@end

@implementation HRPGFAQTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topHeaderCoordinator.hideHeader = true;

    [self setupTableView];
    
    self.searchBar =
        [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    UIButton *resetTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 70)];
    [resetTutorialButton setTitle:NSLocalizedString(@"Reset Justins Tips", nil) forState:UIControlStateNormal];
    [resetTutorialButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
    [resetTutorialButton addTarget:self action:@selector(resetTutorials) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = resetTutorialButton;
}

- (void) setupTableView {
    __weak HRPGFAQTableViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, FAQ *faq, NSIndexPath *indexPath) {
        cell.textLabel.text = faq.question;
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        if (weakSelf.searchText && weakSelf.searchText.length > 0) {
            NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"question CONTAINS[cd] %@", weakSelf.searchText];
            
            [fetchRequest setPredicate:predicate];
        } else {
            [fetchRequest setPredicate:nil];
        }
        
        NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *sortDescriptors = @[ indexDescriptor ];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"FAQ"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FAQ *faq = [self.dataSource itemAtIndexPath:indexPath];

        CGFloat width = self.viewWidth - 51;

        CGFloat height =
            [faq.question boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{
                                        NSFontAttributeName :
                                            [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                    }
                                       context:nil]
                .size.height;
        height = height + 32;
        return height;
    } else {
        CGFloat height = [@" " boundingRectWithSize:CGSizeMake(self.viewWidth, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                             NSFontAttributeName : [UIFont
                                                 preferredFontForTextStyle:UIFontTextStyleBody]
                                         }
                                            context:nil]
                             .size.height;
        height = height + 32;
        return height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        [self performSegueWithIdentifier:@"FAQDetailSegue"
                                  sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FAQDetailSegue"]) {
        HRPGFAQDetailViewController *detailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        FAQ *faq = [self.dataSource itemAtIndexPath:indexPath];
        detailViewController.faq = faq;
    }
}

#pragma mark - Search
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    [self.dataSource reconfigureFetchRequest];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    self.searchText = nil;
    [self.dataSource reconfigureFetchRequest];
    
    [searchBar resignFirstResponder];
}

- (void)resetTutorials {
    NSMutableDictionary *steps = [NSMutableDictionary dictionary];
    for (TutorialSteps *step in [[HRPGManager sharedManager] user].flags.iOSTutorialSteps) {
        step.wasShown = @NO;
        step.shownInView = nil;
        steps[[NSString stringWithFormat:@"flags.tutorial.ios.%@", step.identifier]] = @NO;
    }
    for (TutorialSteps *step in [[HRPGManager sharedManager] user].flags.commonTutorialSteps) {
        step.wasShown = @NO;
        step.shownInView = nil;
        steps[[NSString stringWithFormat:@"flags.tutorial.common.%@", step.identifier]] = @NO;
    }
    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];
    [[HRPGManager sharedManager] updateUser:steps onSuccess:nil onError:nil];
}

@end
