//
//  HRPGClassCollectionViewController.m
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGClassTableViewController.h"
#import <Google/Analytics.h>
#import "Amplitude.h"
#import "HRPGAppDelegate.h"
#import "HRPGWebViewController.h"
#import "UIColor+Habitica.h"
#import "Amplitude.h"
#import "UIViewcontroller+TutorialSteps.h"
#import "Habitica-Swift.h"

@interface HRPGClassTableViewController ()
@property CGSize screenSize;
@property NSArray *classesArray;
@property User *user;

@property BOOL classWasUnset;
@end

@implementation HRPGClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tutorialIdentifier = @"classes";
    self.classWasUnset = NO;

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:@"pageview" forKey:@"hitType"];
    [eventProperties setValue:NSStringFromClass([self class]) forKey:@"page"];
    [[Amplitude instance] logEvent:@"navigate" withEventProperties:eventProperties];

    self.managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
    self.user = [[HRPGManager sharedManager] getUser];

    self.clearsSelectionOnViewWillAppear = NO;

    self.screenSize = [[UIScreen mainScreen] bounds].size;

    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_help"];

    [self loadClassesArray];

    if (self.shouldResetClass) {
        [[HRPGManager sharedManager] changeClass:nil
                              onSuccess:^{
                                  self.classWasUnset = YES;
                              }
                                onError:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self displayTutorialStep:[HRPGManager sharedManager]];
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"classes"]) {
        return @{
            @"text" :
                NSLocalizedString(@"Choose to become a Warrior, Mage, Healer, or Rogue! Each class "
                                  @"has unique equipment and skills. Tap the (?) to learn more!",
                                  nil)
        };
    }
    return nil;
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"There comes a point in the life of every habitican, when they have "
                             @"to decide their path.\n\nWhat will yours be?",
                             nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text = [self tableView:tableView titleForHeaderInSection:section];
    CGFloat height = [text boundingRectWithSize:CGSizeMake(self.screenSize.width - 16, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{
                                         NSFontAttributeName : [UIFont
                                             preferredFontForTextStyle:UIFontTextStyleHeadline]
                                     }
                                        context:nil]
                         .size.height;
    UIView *view =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenSize.width, height + 20.0)];
    UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(8, 14, self.screenSize.width - 16, height)];
    label.text = text;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    label.numberOfLines = 0;
    label.textColor = [UIColor darkGrayColor];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *text = [self tableView:tableView titleForHeaderInSection:section];
    return [text boundingRectWithSize:CGSizeMake(self.screenSize.width - 16, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{
                               NSFontAttributeName :
                                   [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                           }
                              context:nil]
               .size.height +
           20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 4) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"OptOutCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"I want to opt-out", nil);
        cell.textLabel.textColor = [UIColor red100];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.detailTextLabel.text = NSLocalizedString(
            @"Can't be bothered with classes? Want to choose later? Opt out - you'll be a warrior "
            @"and your points handled automatically. You can enable classes later under Settings.",
            nil);
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        return cell;
    } else {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        NSArray *item = self.classesArray[indexPath.item];

        UILabel *label = (UILabel *)[cell viewWithTag:1];
        UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:2];
        UIView *avatarView = (UIView *)[cell viewWithTag:3];

        label.text = item[0];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        descriptionLabel.text = item[1];
        descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        User *classUser = item[2];

        [classUser setAvatarSubview:avatarView showsBackground:NO showsMount:YES showsPet:YES];

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 4) {
        CGFloat height = 24;
        CGFloat textWidth = self.screenSize.width - 16;
        height = height +
                 [NSLocalizedString(@"I want to opt-out", nil)
                     boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{
                                   NSFontAttributeName :
                                       [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                               }
                                  context:nil]
                     .size.height;
        height = height +
                 [NSLocalizedString(@"Can't be bothered with classes? Want to choose later? Opt "
                                    @"out - you'll be a warrior and your points handled "
                                    @"automatically. You can enable classes later under Settings.",
                                    nil)
                     boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{
                                   NSFontAttributeName :
                                       [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                               }
                                  context:nil]
                     .size.height;

        return height;
    }

    // Total width minus width of Image and margins
    CGFloat textWidth = self.screenSize.width - 164;
    // Top margin, margin between labels and bottom margin
    CGFloat height = 25;
    NSArray *item = self.classesArray[indexPath.item];
    // Height for class name
    height = height +
             [item[0] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{
                                    NSFontAttributeName :
                                        [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                }
                                   context:nil]
                 .size.height;
    // Height for class description
    height = height +
             [item[1] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{
                                    NSFontAttributeName :
                                        [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                }
                                   context:nil]
                 .size.height;

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldResetClass && !self.classWasUnset) {
        return;
    }

    self.selectedIndex = indexPath;
    if (indexPath.item == 4) {
        HabiticaAlertController *alertController =
        [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                        message:nil];
        [alertController addCancelActionWithHandler:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"Opt-Out", nil) style:UIAlertActionStyleDefault isMainAction:YES handler:^(UIButton * _Nonnull button) {
            [self alertClickedButtonAtIndex:1];
        }];
        [alertController show];
    } else {
        NSString *className = self.classesArray[indexPath.item][0];
        HabiticaAlertController *alertController = [HabiticaAlertController
                                              alertWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                              message:[NSString
                                                       stringWithFormat:NSLocalizedString(@"You will become a %@.", nil), className]];
        
        [alertController addCancelActionWithHandler:nil];
        
        [alertController addActionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"I want to become a %@", nil), className] style:UIAlertActionStyleDefault isMainAction:YES handler:^(UIButton * _Nonnull button) {
            [self alertClickedButtonAtIndex:1];
        }];
        [alertController show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HelpSegue"]) {
        HRPGWebViewController *webViewController = segue.destinationViewController;
        webViewController.url = [NSURL URLWithString:@"http://habitrpg.wikia.com/wiki/Class_System"];
    }
}

- (void)loadClassesArray {
    User *warrior = [self setUpClassUserWithClass:@"Warrior"];
    warrior.equipped.armor = @"armor_warrior_5";
    warrior.equipped.head = @"head_warrior_5";
    warrior.equipped.shield = @"shield_warrior_5";
    warrior.equipped.weapon = @"weapon_warrior_6";
    User *mage = [self setUpClassUserWithClass:@"Mage"];
    mage.equipped.armor = @"armor_wizard_5";
    mage.equipped.head = @"head_wizard_5";
    mage.equipped.weapon = @"weapon_wizard_6";
    User *rogue = [self setUpClassUserWithClass:@"Rogue"];
    rogue.equipped.armor = @"armor_rogue_5";
    rogue.equipped.head = @"head_rogue_5";
    rogue.equipped.shield = @"shield_rogue_6";
    rogue.equipped.weapon = @"weapon_rogue_6";
    User *healer = [self setUpClassUserWithClass:@"Healer"];
    healer.equipped.armor = @"armor_healer_5";
    healer.equipped.head = @"head_healer_5";
    healer.equipped.shield = @"shield_healer_5";
    healer.equipped.weapon = @"weapon_healer_6";

    self.classesArray = @[
        @[
           NSLocalizedString(@"Warrior", nil),
           NSLocalizedString(@"Warriors score more and better \"critical hits\", which randomly "
                             @"give bonus Gold, Experience, and drop chance for scoring a task. "
                             @"They also deal heavy damage to boss monsters. Play a Warrior if "
                             @"you find motivation from unpredictable jackpot-style rewards, or "
                             @"want to dish out the hurt in boss Quests!",
                             nil),
           warrior, @"warrior"
        ],
        @[
           NSLocalizedString(@"Mage", nil),
           NSLocalizedString(@"Mages learn swiftly, gaining Experience and Levels faster than "
                             @"other classes. They also get a great deal of Mana for using "
                             @"special abilities. Play a Mage if you enjoy the tactical game "
                             @"aspects of Habit, or if you are strongly motivated by leveling up "
                             @"and unlocking advanced features!",
                             nil),
           mage, @"wizard"
        ],
        @[
           NSLocalizedString(@"Rogue", nil),
           NSLocalizedString(@"Rogues love to accumulate wealth, gaining more Gold than anyone "
                             @"else, and are adept at finding random items. Their iconic Stealth "
                             @"ability lets them duck the consequences of missed Dailies. Play a "
                             @"Rogue if you find strong motivation from Rewards and Achievements, "
                             @"striving for loot and badges!",
                             nil),
           rogue, @"rogue"
        ],
        @[
           NSLocalizedString(@"Healer", nil),
           NSLocalizedString(@"Healers stand impervious against harm, and extend that protection "
                             @"to others. Missed Dailies and bad Habits don't faze them much, and "
                             @"they have ways to recover Health from failure. Play a Healer if "
                             @"you enjoy assisting others in your Party, or if the idea of "
                             @"cheating Death through hard work inspires you!",
                             nil),
           healer, @"healer"
        ],
    ];
}

- (User *)setUpClassUserWithClass:(NSString *)className {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    User *user = (User *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    entity = [NSEntityDescription entityForName:@"Preferences"
                         inManagedObjectContext:self.managedObjectContext];
    user.preferences =
        (Preferences *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    entity = [NSEntityDescription entityForName:@"Outfit"
                         inManagedObjectContext:self.managedObjectContext];
    user.equipped =
        (Outfit *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    user.username = [self.user.username stringByAppendingString:className];
    user.preferences.skin = self.user.preferences.skin;
    user.preferences.hairBangs = self.user.preferences.hairBangs;
    user.preferences.hairBase = self.user.preferences.hairBase;
    user.preferences.hairBeard = self.user.preferences.hairBeard;
    user.preferences.hairColor = self.user.preferences.hairColor;
    user.preferences.hairMustache = self.user.preferences.hairMustache;
    user.preferences.shirt = self.user.preferences.shirt;
    user.preferences.size = self.user.preferences.size;

    return user;
}

- (void)alertClickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
    } else {
        if (self.selectedIndex.item == 4) {
            [[HRPGManager sharedManager] disableClasses:^() {
                                     if (self.navigationController.viewControllers.count > 1) {
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } else {
                                         [self.presentingViewController
                                             dismissViewControllerAnimated:YES
                                                                completion:^(){}];
                                     }
                                 }
                                   onError:nil];
        } else {
            [[HRPGManager sharedManager]
                changeClass:self.classesArray[self.selectedIndex.item][3]
                  onSuccess:^() {
                      [[HRPGManager sharedManager] fetchUser:^() {
                          if (self.navigationController.viewControllers.count > 1) {
                              [self.navigationController popViewControllerAnimated:YES];
                          } else {
                              [self.presentingViewController dismissViewControllerAnimated:YES
                                                                                completion:^(){
                                                                                }];
                          }
                      }
                          onError:^() {
                              if (self.navigationController.viewControllers.count > 1) {
                                  [self.navigationController popViewControllerAnimated:YES];
                              } else {
                                  [self.presentingViewController dismissViewControllerAnimated:YES
                                                                                    completion:^(){}];
                              }
                          }];
                  }
                    onError:nil];
        }
        [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
    }
}

@end
