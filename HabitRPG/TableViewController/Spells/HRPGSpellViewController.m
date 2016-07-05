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
@interface HRPGSpellViewController ()
@property User *user;
@property HRPGCoreDataDataSource *dataSource;
@end

@implementation HRPGSpellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
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
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, Spell *skill, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withSkill:skill withAnimation:YES];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        User *user = [weakSelf.sharedManager getUser];
        NSString *classname = [NSString stringWithFormat:@"%@", user.dirtyClass];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"klass == %@ && level <= %@",
                                    classname, user.level]];
        
        NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
        NSArray *sortDescriptors = @[ sortDescriptor ];
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"Spell"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
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
        } else {
            [self.sharedManager castSpell:spell.key
                           withTargetType:spell.target
                                 onTarget:nil
                                onSuccess:^() {
                                    [tableView reloadData];
                                }
                                  onError:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 30.0f;
    float width = self.viewWidth - 43;
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

- (void)configureCell:(UITableViewCell *)cell
          withSkill:(Spell *)skill
        withAnimation:(BOOL)animate {
    UILabel *nameLabel = [cell viewWithTag:1];
    UILabel *detailLabel = [cell viewWithTag:2];
    UILabel *manaLabel = [cell viewWithTag:3];
    nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    manaLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    nameLabel.text = skill.text;
    detailLabel.text = skill.notes;
    manaLabel.text = [NSString stringWithFormat:@"%@ MP", skill.mana];
    if ([self.user.magic integerValue] >= [skill.mana integerValue]) {
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

@end
