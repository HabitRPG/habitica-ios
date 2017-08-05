//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSpellViewController.h"
#import "HRPGSpellTabBarController.h"
#import "Spell.h"
#import "HRPGCoreDataDataSource.h"
#import "HRPGSpellTableViewCell.h"
#import "HRPGSpellUserTableViewController.h"

@interface HRPGSpellViewController ()
@property User *user;
@property HRPGCoreDataDataSource *dataSource;
@end

@implementation HRPGSpellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [[HRPGManager sharedManager] getUser];
    [self setupTableView];
    self.tutorialIdentifier = @"skills";

    if ([self.user.hclass isEqualToString:@"wizard"] ||
        [self.user.hclass isEqualToString:@"healer"]) {
        self.navigationItem.title = NSLocalizedString(@"Cast Spells", nil);
    } else {
        self.navigationItem.title = NSLocalizedString(@"Use Skills", nil);
    }
}

- (void) setupTableView {
    __weak HRPGSpellViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(HRPGSpellTableViewCell *cell, Spell *skill, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withSkill:skill withAnimation:YES];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        [fetchRequest setPredicate:[weakSelf predicate]];
        
        NSSortDescriptor *classSortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"klass" ascending:NO];
        NSSortDescriptor *levelSortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
        NSArray *sortDescriptors = @[ classSortDescriptor, levelSortDescriptor ];
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"Spell"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
    self.dataSource.sectionNameKeyPath = @"klass";
    self.dataSource.haveEmptyHeaderTitles = YES;
    self.dataSource.emptyText = NSLocalizedString(@"You don't have any spells yet. Continue completing your tasks and level up to unlock some!", nil);
}

- (NSPredicate *)predicate {
    User *user = [[HRPGManager sharedManager] getUser];
    NSString *classname = [NSString stringWithFormat:@"%@", user.dirtyClass];
    NSArray *ownedTransoformationIDs = [user.specialItems ownedTransformationItemIDs];
    if (ownedTransoformationIDs == nil) {
        return [NSPredicate predicateWithFormat:@"klass == %@ && level <= %@",
                classname, user.level];
    } else {
        return [NSPredicate predicateWithFormat:@"(klass == %@ && level <= %@) || (klass=='special' && key IN %@)",
            classname, user.level, [user.specialItems ownedTransformationItemIDs]];
    }
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"skills"]) {
        return @{
            @"text" :
                NSLocalizedString(@"Skills are special abilities that have powerful effects! Tap "
                                  @"on a skill to use it. It will cost Mana (the blue bar), which "
                                  @"you earn by checking in every day and by completing your "
                                  @"real-life tasks. Check out the FAQ in the menu for more info!",
                                  nil)
        };
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Spell *spell = [self.dataSource itemAtIndexPath:indexPath];
    __weak HRPGSpellViewController *weakSelf = self;
    if ([self.user.magic integerValue] >= [spell.mana integerValue]) {
        if ([spell.target isEqualToString:@"task"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navigationController = [storyboard
                instantiateViewControllerWithIdentifier:@"spellTaskNavigationController"];

            [self presentViewController:navigationController
                               animated:YES
                             completion:^() {
                                 HRPGSpellTabBarController *tabBarController =
                                     (HRPGSpellTabBarController *)
                                         navigationController.topViewController;
                                 tabBarController.spell = spell;
                                 tabBarController.sourceTableView = self.tableView;
                             }];
        } else if ([spell.target isEqualToString:@"user"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navigationController = [storyboard
                                                            instantiateViewControllerWithIdentifier:@"SpellUserNavigationController"];
            [self presentViewController:navigationController
                               animated:YES
                             completion:^() {
                                 HRPGSpellUserTableViewController *tabBarController =
                                 (HRPGSpellUserTableViewController *)
                                 navigationController.topViewController;
                                 tabBarController.spell = spell;
                             }];

        } else {
            [[HRPGManager sharedManager] castSpell:spell
                           withTargetType:spell.target
                                 onTarget:nil
                                onSuccess:^() {
                                    [weakSelf.tableView reloadData];
                                }
                                  onError:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 30.0f;
    float width = self.viewWidth - 83;
    Spell *spell = [self.dataSource itemAtIndexPath:indexPath];
    width = width -
            [[NSString stringWithFormat:@"%ld MP", (long)[spell.mana integerValue]]
                boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{
                              NSFontAttributeName :
                                  [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                          }
                             context:nil]
                .size.width;
    height = height +
             [spell.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{
                                       NSFontAttributeName : [UIFont
                                           preferredFontForTextStyle:UIFontTextStyleHeadline]
                                   }
                                      context:nil]
                 .size.height;
    if ([spell.notes length] > 0) {
        height = height +
                 [spell.notes
                     boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{
                                   NSFontAttributeName :
                                       [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                               }
                                  context:nil]
                     .size.height;
    }
    return height;
}

- (void)configureCell:(HRPGSpellTableViewCell *)cell
          withSkill:(Spell *)skill
        withAnimation:(BOOL)animate {
    NSNumber *ownedSpecials = nil;
    if ([skill.klass isEqualToString:@"special"]) {
        ownedSpecials = [self.user.specialItems valueForKey:skill.key];
    }
    [cell configureForSpell:skill withMagic:self.user.magic withOwned:ownedSpecials];
    [[HRPGManager sharedManager] setImage:[@"shop_" stringByAppendingString:skill.key] withFormat:@"png" onView:cell.spellImageView];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}


- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"CastUserSpellSegue"]) {
        HRPGSpellUserTableViewController *userViewController = (HRPGSpellUserTableViewController *) segue.sourceViewController;
        [[HRPGManager sharedManager] castSpell:userViewController.spell withTargetType:@"user" onTarget:userViewController.userID onSuccess:^{
            [self.tableView reloadData];
        } onError:nil];
        
    }
}
@end
