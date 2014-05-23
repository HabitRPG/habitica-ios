//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGRewardsViewController.h"
#import "HRPGAppDelegate.h"
#import <PDKeychainBindings.h>

@interface HRPGRewardsViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@property NSIndexPath *openedIndexPath;
@property int indexOffset;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate;
@end

@implementation HRPGRewardsViewController
@synthesize managedObjectContext;
@dynamic sharedManager;

UIImageView *goldImageView;
UILabel *goldLabel;
UIImageView *silverImageView;
UILabel *silverLabel;
UIView *moneyView;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];

    if ([keyChain stringForKey:@"id"] == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:navigationController animated:NO completion:nil];
    }

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.text = NSLocalizedString(@"Rewards", nil);
    NSNumber *gold = [self.sharedManager getUser].gold;
    goldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 22)];
    goldImageView.contentMode = UIViewContentModeScaleAspectFit;
    [goldImageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_gold.png"]];
    goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 2, 100, 20)];
    goldLabel.font = [UIFont systemFontOfSize:13.0f];
    goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [gold integerValue]];
    [goldLabel sizeToFit];


    silverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 + goldLabel.frame.size.width, 0, 25, 22)];
    silverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [silverImageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_silver.png"]];
    silverLabel = [[UILabel alloc] initWithFrame:CGRectMake(30 + goldLabel.frame.size.width + 26, 2, 100, 20)];
    silverLabel.font = [UIFont systemFontOfSize:13.0f];
    int silver = ([gold floatValue] - [gold integerValue]) * 100;
    silverLabel.text = [NSString stringWithFormat:@"%d", silver];
    [silverLabel sizeToFit];


    int moneyWidth = goldImageView.frame.size.width + goldLabel.frame.size.width + silverImageView.frame.size.width + silverLabel.frame.size.width + 7;

    moneyView = [[UIView alloc] initWithFrame:CGRectMake(50 - (moneyWidth / 2), 20, moneyWidth, 40)];
    [moneyView addSubview:goldLabel];
    [moneyView addSubview:goldImageView];
    [moneyView addSubview:silverImageView];
    [moneyView addSubview:silverLabel];

    [titleView addSubview:titleLabel];
    [titleView addSubview:moneyView];

    self.navigationItem.titleView = titleView;
}

- (void)refresh {
    [self.sharedManager fetchUser:^() {
        [self.refreshControl endRefreshing];
    }                     onError:^() {
        [self.refreshControl endRefreshing];
        [self.sharedManager displayNetworkError];
    }];
}

- (IBAction)updateRewardView:(NSString *)amount {
    NSNumber *gold = [self.sharedManager getUser].gold;
    goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [gold integerValue]];
    [goldLabel sizeToFit];

    int silver = ([gold floatValue] - [gold integerValue]) * 100;
    silverLabel.text = [NSString stringWithFormat:@"%d", silver];
    silverLabel.frame = CGRectMake(30 + goldLabel.frame.size.width + 26, 2, 100, 16);

    [silverLabel sizeToFit];
    silverImageView.frame = CGRectMake(30 + goldLabel.frame.size.width, 0, 25, 22);

    int moneyWidth = goldImageView.frame.size.width + goldLabel.frame.size.width + silverImageView.frame.size.width + silverLabel.frame.size.width + 7;

    moneyView.frame = CGRectMake(50 - (moneyWidth / 2), 20, moneyWidth, 40);

    UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, goldLabel.frame.origin.y, goldLabel.frame.size.width + goldLabel.frame.origin.x, 16)];
    updateLabel.font = [UIFont systemFontOfSize:13.0f];
    updateLabel.textAlignment = NSTextAlignmentRight;
    updateLabel.text = amount;
    updateLabel.textColor = [UIColor redColor];
    [moneyView addSubview:updateLabel];
    [UIView animateWithDuration:0.3 animations:^() {
        updateLabel.frame = CGRectMake(0, 25, goldLabel.frame.size.width + goldLabel.frame.origin.x, 16);
        updateLabel.alpha = 0.0f;
    }                completion:^(BOOL completition) {
        [updateLabel removeFromSuperview];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.fetchedResultsController sections][section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects] + self.indexOffset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([reward.key isEqualToString:@"potion"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 22.0f;
    float width = 270.0f;
    if (indexPath.section == 1) {
        width = 229.0f;
    }
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    width = width - [[NSString stringWithFormat:@"%ld", (long) [reward.value integerValue]] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                      attributes:@{
                                                                                                              NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                                                                      }
                                                                                                         context:nil].size.width;
    height = height + [reward.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                     NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                             }
                                                context:nil].size.height;
    if ([reward.notes length] > 0) {
        height = height + [reward.notes boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                                  }
                                                     context:nil].size.height;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([reward.type isEqualToString:@"reward"]) {
        [self.sharedManager getReward:reward.key onSuccess:^() {
            [self updateRewardView:[reward.value stringValue]];
        }                     onError:^() {

        }];
    } else {
        [self.sharedManager buyObject:reward onSuccess:^() {
            [self updateRewardView:[reward.value stringValue]];
        }                     onError:^() {

        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)editButtonSelected:(id)sender {
    if ([self isEditing]) {
        [self setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected:)];
    } else {
        [self setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonSelected:)];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {

}


- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {

}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaReward" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"type=='potion' || type=='reward'"];
    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    NSSortDescriptor *keyDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:NO];
    NSArray *sortDescriptors = @[typeDescriptor, keyDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"type" cacheName:@"rewards"];
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
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withAnimation:YES];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    MetaReward *reward = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel *) [cell viewWithTag:1];
    textLabel.text = reward.text;
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [textLabel sizeToFit];
    UILabel *notesLabel = (UILabel *) [cell viewWithTag:2];
    notesLabel.text = reward.notes;
    notesLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [notesLabel sizeToFit];
    UILabel *priceLabel = (UILabel *) [cell viewWithTag:3];
    priceLabel.text = [NSString stringWithFormat:@"%ld", (long) [reward.value integerValue]];
    [priceLabel sizeToFit];
    UIImageView *goldView = (UIImageView *) [cell viewWithTag:4];
    [goldView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_gold.png"]
             placeholderImage:nil];

    if ([reward.key isEqualToString:@"potion"]) {
        UIImageView *imageView = (UIImageView *) [cell viewWithTag:5];
        [imageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_potion.png"]
                  placeholderImage:nil];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
