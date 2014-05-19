//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSpellViewController.h"
#import "HRPGAppDelegate.h"
#import "Task.h"
#import <PDKeychainBindings.h>
#import "Spell.h"

@interface HRPGSpellViewController ()
@property HRPGManager *sharedManager;
@property User *user;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL) animate;
@end

@implementation HRPGSpellViewController
@synthesize managedObjectContext;
@dynamic sharedManager;


-(void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Spell *spell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.user.magic integerValue] >= [spell.mana integerValue]) {
        if ([spell.target isEqualToString:@"task"]) {
        
        } else {
            [self.sharedManager castSpell:spell.key withTargetType:spell.target onTarget:nil onSuccess:^() {
                [tableView reloadData];
            }onError:^() {
                
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 22.0f;
    float width = 277.0f;
    Spell *spell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    width = width - [[NSString stringWithFormat:@"%ld MP", (long)[spell.mana integerValue]] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                     attributes:@{
                                                                                                                  NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                                                                                  }
                                                                                context:nil].size.width;
    height = height + [spell.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                                          }
                                                context:nil].size.height;
    if ([spell.notes length] > 0) {
        height = height + [spell.notes boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                               NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                                               }
                                                     context:nil].size.height;
    }
    return height;
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


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Spell" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    User *user = [self.sharedManager getUser];
    NSString *classname = [NSString stringWithFormat:@"spells.%@", user.hclass];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"klass == %@ && level <= %@", classname, user.level]];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
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
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate
{
    Spell *spell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:1];
    UILabel *detailLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *manaLabel = (UILabel*)[cell viewWithTag:3];
    nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    manaLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    nameLabel.text = spell.text;
    detailLabel.text = spell.notes;
    manaLabel.text = [NSString stringWithFormat:@"%@ MP", spell.mana];
    if ([self.user.magic integerValue] >= [spell.mana integerValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        nameLabel.textColor = [UIColor darkTextColor];
        detailLabel.textColor = [UIColor darkTextColor];
        manaLabel.textColor = [UIColor darkTextColor];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        nameLabel.textColor = [UIColor lightGrayColor];
        detailLabel.textColor = [UIColor lightGrayColor];
        manaLabel.textColor = [UIColor lightGrayColor];
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
