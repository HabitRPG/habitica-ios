//
//  HRPGUserProfileViewController.m
//  Habitica
//
//  Created by Phillip on 13/07/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGUserProfileViewController.h"
#import "HRPGLabeledProgressBar.h"
#import "UIColor+Habitica.h"
#import "UIViewController+Markdown.h"
#import "HRPGInboxChatViewController.h"
#import "Outfit.h"
#import "Gear.h"
#import "Habitica-Swift.h"

@interface HRPGUserProfileViewController ()
@property(nonatomic, readonly, getter=getUser) User *user;
@property NSDictionary *gearDictionary;
@property BOOL isAttributesExpanded;
@end

@implementation HRPGUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topHeaderCoordinator.hideHeader = NO;
    self.topHeaderCoordinator.followScrollView = YES;
    self.topHeaderNavigationController.shouldHideTopHeader = NO;

    [[HRPGManager sharedManager] fetchMember:self.userID
        onSuccess:nil onError:nil];

    self.navigationItem.title = self.username;
    
    self.isAttributesExpanded = NO;
    
    [self createGearDictionary];
}

- (void)refresh {
}

- (User *)getUser {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            return (User *)[self.fetchedResultsController
                objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (void)createGearDictionary {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableDictionary *gearDict = [NSMutableDictionary dictionaryWithCapacity:results.count];
    for (Gear *gear in results) {
        [gearDict setObject:gear forKey:gear.key];
    }
    self.gearDictionary = gearDict;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.user) {
        return 4;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
        case 1:
            return NSLocalizedString(@"Battle Gear", nil);
        case 2:
            return NSLocalizedString(@"Costume", nil);
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
        case 1:
        case 2:
            return 8;
        case 3: {
            if (self.isAttributesExpanded) {
                return 7;
            } else {
                return 2;
            }
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellname = @"Cell";
    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 0:
                    cellname = @"ProfileCell";
                    break;
                case 1:
                    cellname = @"TextCell";
                    break;
                case 2:
                    cellname = @"SubtitleCell";
                    break;
                case 3:
                    cellname = @"SubtitleCell";
                    break;
            }
            break;
        case 1:
        case 2:
            cellname = @"EquipmentCell";
            break;
        case 3: {
            if (indexPath.item == 0) {
                cellname = @"AttributeHeaderCell";
            } else {
                cellname = @"AttributeCell";
            }
            break;
        }
        default:
            cellname = @"";
            break;
    }
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 0:
                    [self configureCell:cell atIndexPath:indexPath];
                    break;
                case 1: {
                    UITextView *textView = [cell viewWithTag:1];
                    textView.attributedText = [self renderMarkdown:self.user.blurb];
                    break;
                }
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"Member Since", nil);
                    cell.detailTextLabel.text =
                    [NSDateFormatter localizedStringFromDate:self.user.memberSince
                                                   dateStyle:NSDateFormatterMediumStyle
                                                   timeStyle:NSDateFormatterNoStyle];
                    break;
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"Last logged in", nil);
                    cell.detailTextLabel.text =
                    [NSDateFormatter localizedStringFromDate:self.user.lastLogin
                                                   dateStyle:NSDateFormatterMediumStyle
                                                   timeStyle:NSDateFormatterNoStyle];
                    break;
            }
            break;
        case 1:
        case 2: {
            Outfit *outfit;
            if (indexPath.section == 1) {
                outfit = self.user.equipped;
            } else {
                outfit = self.user.costume;
            }
            [self configureEquipmentCell:cell atIndex:indexPath.item withOutfit:outfit];
            break;
        }
        case 3: {
            if (indexPath.item > 0) {
                [self configureAttributeCell:cell atIndex:indexPath.item];
            }
        }
    }
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        self.isAttributesExpanded = !self.isAttributesExpanded;
        NSArray *rowsArray = @[[NSIndexPath indexPathForRow:1 inSection:3], [NSIndexPath indexPathForRow:2 inSection:3], [NSIndexPath indexPathForRow:3 inSection:3], [NSIndexPath indexPathForRow:4 inSection:3], [NSIndexPath indexPathForRow:5 inSection:3]];
        if (self.isAttributesExpanded) {
            [self.tableView insertRowsAtIndexPaths:rowsArray withRowAnimation:UITableViewRowAnimationTop];
        } else {
            [self.tableView deleteRowsAtIndexPaths:rowsArray withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 147;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        return [[self renderMarkdown:self.user.blurb]
                   boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin
                                context:nil]
                   .size.height +
               41;
    } else if (indexPath.section == 1 || indexPath.section == 2) {
        return 60;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }

    return [super tableView:tableView viewForHeaderInSection:section];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.userID]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[ sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath usForce:NO];
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
              usForce:(BOOL)force {
    if (indexPath.section == 0 && indexPath.item == 0) {
        User *user = (User *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        UILabel *levelLabel = [cell viewWithTag:1];
        levelLabel.text =
            [NSString stringWithFormat:NSLocalizedString(@"Level %@", nil), user.level];

        HRPGLabeledProgressBar *healthLabel = [cell viewWithTag:2];
        healthLabel.color = [UIColor red100];
        healthLabel.icon = HabiticaIcons.imageOfHeartLightBg;
        healthLabel.type = NSLocalizedString(@"Health", nil);
        healthLabel.value = user.health;
        healthLabel.maxValue = @50;

        HRPGLabeledProgressBar *experienceLabel = [cell viewWithTag:3];
        experienceLabel.color = [UIColor yellow100];
        experienceLabel.icon = HabiticaIcons.imageOfExperience;
        experienceLabel.type = NSLocalizedString(@"Experience", nil);
        experienceLabel.value = user.experience;
        experienceLabel.maxValue = user.nextLevel;

        HRPGLabeledProgressBar *magicLabel = [cell viewWithTag:4];

        if ([user.level integerValue] >= 10) {
            magicLabel.color = [UIColor blue100];
            magicLabel.icon = HabiticaIcons.imageOfMagic;
            magicLabel.type = NSLocalizedString(@"Mana", nil);
            magicLabel.value = user.magic;
            magicLabel.maxValue = user.maxMagic;
            magicLabel.hidden = NO;
        } else {
            magicLabel.hidden = YES;
        }
        UIView *avatarView = (UIView *)[cell viewWithTag:8];
        [user setAvatarSubview:avatarView showsBackground:YES showsMount:YES showsPet:YES];
    }
}

- (void) configureEquipmentCell:(UITableViewCell *)cell atIndex:(NSInteger)index withOutfit:(Outfit *)outfit {
    UILabel *typeLabel = [cell viewWithTag:1];
    UILabel *attrLabel = [cell viewWithTag:2];
    UILabel *detailTextLabel = [cell viewWithTag:3];
    UIImageView *imageView = [cell viewWithTag:4];
    
    NSString *equipmentKey = nil;
    NSString *typeName = nil;
    switch (index) {
        case 0:
            equipmentKey = outfit.head;
            typeName = NSLocalizedString(@"Head", nil);
            break;
        case 1:
            equipmentKey = outfit.headAccessory;
            typeName = NSLocalizedString(@"Head Accessory", nil);
            break;
        case 2:
            equipmentKey = outfit.eyewear;
            typeName = NSLocalizedString(@"Eyewear", nil);
            break;
        case 3:
            equipmentKey = outfit.armor;
            typeName = NSLocalizedString(@"Armor", nil);
            break;
        case 4:
            equipmentKey = outfit.body;
            typeName = NSLocalizedString(@"Body", nil);
            break;
        case 5:
            equipmentKey = outfit.back;
            typeName = NSLocalizedString(@"Back", nil);
            break;
        case 6:
            equipmentKey = outfit.shield;
            typeName = NSLocalizedString(@"Shield", nil);
            break;
        case 7:
            equipmentKey = outfit.weapon;
            typeName = NSLocalizedString(@"Weapon", nil);
            break;
            
    }
    
    typeLabel.text = typeName;
    if (equipmentKey) {
        [[HRPGManager sharedManager] setImage:[NSString stringWithFormat:@"shop_%@", equipmentKey]
                          withFormat:@"png"
                              onView:imageView];
        
        Gear *gear = [self.gearDictionary objectForKey:equipmentKey];
        
        detailTextLabel.text = gear.text;
        detailTextLabel.textColor = [UIColor blackColor];
        attrLabel.text = [gear statsText];
    } else {
        detailTextLabel.text = NSLocalizedString(@"Nothing equipped", nil);
        detailTextLabel.textColor = [UIColor grayColor];
        attrLabel.text = nil;
    }
}

- (void)configureAttributeCell:(UITableViewCell *)cell atIndex:(NSInteger)index {
    UILabel *descriptionLabel = [cell viewWithTag:1];
    UILabel *strLabel = [cell viewWithTag:2];
    UILabel *intLabel = [cell viewWithTag:3];
    UILabel *conLabel = [cell viewWithTag:4];
    UILabel *perLabel = [cell viewWithTag:5];

    int strValue = 0;
    int intValue = 0;
    int conValue = 0;
    int perValue = 0;
    
    if ((index == 1 && !self.isAttributesExpanded) || index == 6) {
        descriptionLabel.text = nil;
        NSDictionary *levelValues = [self levelAttributes];
        NSDictionary *gearValues = [self gearAttributes];
        NSDictionary *classBonusValues = [self classBonusAttributes];
        NSDictionary *allocatedValues = [self allocatedAttributes];
        NSDictionary *buffedValues = [self buffedAttributes];
        
        strValue = [levelValues[@"str"] intValue] + [gearValues[@"str"] intValue] + [classBonusValues[@"str"] intValue] + [allocatedValues[@"str"] intValue] + [buffedValues[@"str"] intValue];
        intValue = [levelValues[@"int"] intValue] + [gearValues[@"int"] intValue] + [classBonusValues[@"int"] intValue] + [allocatedValues[@"int"] intValue] + [buffedValues[@"int"] intValue];
        conValue = [levelValues[@"con"] intValue] + [gearValues[@"con"] intValue] + [classBonusValues[@"con"] intValue] + [allocatedValues[@"con"] intValue] + [buffedValues[@"con"] intValue];
        perValue = [levelValues[@"per"] intValue] + [gearValues[@"per"] intValue] + [classBonusValues[@"per"] intValue] + [allocatedValues[@"per"] intValue] + [buffedValues[@"per"] intValue];

    } else if (index == 1) {
        descriptionLabel.text = NSLocalizedString(@"Level", nil);
        NSDictionary *values = [self levelAttributes];
        strValue = [values[@"str"] intValue];
        intValue = [values[@"int"] intValue];
        conValue = [values[@"con"] intValue];
        perValue = [values[@"per"] intValue];
    } else if (index == 2) {
        descriptionLabel.text = NSLocalizedString(@"Battle Gear", nil);
        NSDictionary *values = [self gearAttributes];
        strValue = [values[@"str"] intValue];
        intValue = [values[@"int"] intValue];
        conValue = [values[@"con"] intValue];
        perValue = [values[@"per"] intValue];
    } else if (index == 3) {
        descriptionLabel.text = NSLocalizedString(@"Class-Bonus", nil);
        NSDictionary *values = [self classBonusAttributes];
        strValue = [values[@"str"] intValue];
        intValue = [values[@"int"] intValue];
        conValue = [values[@"con"] intValue];
        perValue = [values[@"per"] intValue];
    } else if (index == 4) {
        descriptionLabel.text = NSLocalizedString(@"Allocated", nil);
        NSDictionary *values = [self allocatedAttributes];
        strValue = [values[@"str"] intValue];
        intValue = [values[@"int"] intValue];
        conValue = [values[@"con"] intValue];
        perValue = [values[@"per"] intValue];
    } else if (index == 5) {
        descriptionLabel.text = NSLocalizedString(@"Boosts", nil);
        NSDictionary *values = [self buffedAttributes];
        strValue = [values[@"str"] intValue];
        intValue = [values[@"int"] intValue];
        conValue = [values[@"con"] intValue];
        perValue = [values[@"per"] intValue];
    }
    
    strLabel.text = [[NSNumber numberWithInt:strValue] stringValue];
    intLabel.text = [[NSNumber numberWithInt:intValue] stringValue];
    conLabel.text = [[NSNumber numberWithInt:conValue] stringValue];
    perLabel.text = [[NSNumber numberWithInt:perValue] stringValue];
}

- (NSDictionary *) levelAttributes {
    return @{
    @"str": [NSNumber numberWithInt:[self.user.level intValue] * 0.5f],
    @"int": [NSNumber numberWithInt:[self.user.level intValue] * 0.5f],
    @"con": [NSNumber numberWithInt:[self.user.level intValue] * 0.5f],
    @"per": [NSNumber numberWithInt:[self.user.level intValue] * 0.5f]
    };
}

- (NSDictionary *) allocatedAttributes {
    return @{
             @"str": self.user.strength ? self.user.strength : @0,
             @"int": self.user.intelligence ? self.user.intelligence : @0,
             @"con": self.user.constitution ? self.user.constitution : @0,
             @"per": self.user.perception ? self.user.perception : @0
             };
}

- (NSDictionary *) buffedAttributes {
    return @{
             @"str": self.user.buff.strength ? self.user.buff.strength : @0,
             @"int": self.user.buff.intelligence ? self.user.buff.intelligence : @0,
             @"con": self.user.buff.constitution ? self.user.buff.constitution : @0,
             @"per": self.user.buff.perception ? self.user.buff.perception : @0
             };
}

- (NSDictionary *)gearAttributes {
    int strValue = 0;
    int intValue = 0;
    int conValue = 0;
    int perValue = 0;
    for (Gear *gear in [self battleGearList]) {
        strValue = strValue + [gear.str intValue];
        intValue = intValue + [gear.intelligence intValue];
        conValue = conValue + [gear.con intValue];
        perValue = perValue + [gear.per intValue];
    }
    return @{
             @"str": [NSNumber numberWithInt:strValue],
             @"int": [NSNumber numberWithInt:intValue],
             @"con": [NSNumber numberWithInt:conValue],
             @"per": [NSNumber numberWithInt:perValue]
             };
}

- (NSDictionary *)classBonusAttributes {
    int strValue = 0;
    int intValue = 0;
    int conValue = 0;
    int perValue = 0;
    for (Gear *gear in [self battleGearList]) {
        if ([gear.klass isEqualToString:self.user.hclass]) {
            strValue = strValue + [gear.str intValue];
            intValue = intValue + [gear.intelligence intValue];
            conValue = conValue + [gear.con intValue];
            perValue = perValue + [gear.per intValue];
        }
        
    }
    return @{
             @"str": [NSNumber numberWithInt:strValue/2],
             @"int": [NSNumber numberWithInt:intValue/2],
             @"con": [NSNumber numberWithInt:conValue/2],
             @"per": [NSNumber numberWithInt:perValue/2]
             };
}

- (NSArray *)battleGearList {
    NSMutableArray *gearList = [NSMutableArray array];
    Outfit *battleGear = self.user.equipped;
    if (battleGear.head) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.head]];
    }
    if (battleGear.headAccessory) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.headAccessory]];
    }
    if (battleGear.eyewear) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.eyewear]];
    }
    if (battleGear.armor) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.armor]];
    }
    if (battleGear.body) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.body]];
    }
    if (battleGear.back) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.back]];
    }
    if (battleGear.shield) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.shield]];
    }
    if (battleGear.weapon) {
        [gearList addObject:[self.gearDictionary objectForKey:battleGear.weapon]];
    }
    return gearList;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WriteMessageSegue"]) {
        UINavigationController *destinationNavigationController = segue.destinationViewController;
        HRPGInboxChatViewController *chatViewController = (HRPGInboxChatViewController *)destinationNavigationController.topViewController;
        chatViewController.userID = self.userID;
        chatViewController.username = self.username;
        chatViewController.isPresentedModally = YES;
    }
}

@end
