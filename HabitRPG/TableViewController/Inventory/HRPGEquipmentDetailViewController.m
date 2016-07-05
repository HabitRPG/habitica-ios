//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGEquipmentDetailViewController.h"
#import "Gear.h"
#import "HRPGCoreDataDataSource.h"

@interface HRPGEquipmentDetailViewController ()
@property User *user;
@property NSIndexPath *equippedIndex;
@property HRPGCoreDataDataSource *dataSource;
@end

@implementation HRPGEquipmentDetailViewController
Gear *selectedGear;
NSIndexPath *selectedIndex;
float textWidth;

- (void)viewDidLoad {
    self.user = [self.sharedManager getUser];
    [super viewDidLoad];
    [self setupTableView];

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    textWidth = (float)(screenRect.size.width - 73.0);
}

- (void)setupTableView {
    __weak HRPGEquipmentDetailViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, Gear *gear, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withGear:gear atIndexPath:indexPath withAnimation:YES];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"owned == True && type == %@", weakSelf.type];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *indexDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSSortDescriptor *classDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"klass" ascending:YES];
        NSArray *sortDescriptors = @[ classDescriptor, indexDescriptor ];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"Gear"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
    self.dataSource.sectionNameKeyPath = @"klass";
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Gear *gear = [self.dataSource itemAtIndexPath:indexPath];
    float height = 22.0f;
    height = height +
             [gear.text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{
                                      NSFontAttributeName :
                                          [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                  }
                                     context:nil]
                 .size.height;
    height = height +
             [gear.notes boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{
                                       NSFontAttributeName : [UIFont
                                           preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                   }
                                      context:nil]
                 .size.height;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath;
    NSString *gearString;
    Gear *gear = [self.dataSource itemAtIndexPath:indexPath];
    if ([self.equipType isEqualToString:@"equipped"]) {
        if ([gear isEquippedBy:self.user]) {
            gearString = NSLocalizedString(@"Unequip", nil);
        } else {
            gearString = NSLocalizedString(@"Equip", nil);
        }
    } else {
        if ([gear isCostumeOf:self.user]) {
            gearString = NSLocalizedString(@"Unequip", nil);
        } else {
            gearString = NSLocalizedString(@"Equip", nil);
        }
    }
    selectedGear = gear;
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:gearString, nil];
    popup.tag = 1;

    // get the selected cell so that the popup can be displayed near it on the iPad
    UITableViewCell *selectedCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];

    CGRect rectIPad = CGRectMake(selectedCell.frame.origin.x, selectedCell.frame.origin.y,
                                 selectedCell.frame.size.width, selectedCell.frame.size.height);
    // using the following form rather than [popup showInView:[UIApplication
    // sharedApplication].keyWindow]] to make it compatible with both iPhone and iPad
    [popup showFromRect:rectIPad inView:self.view animated:YES];
}


- (void)configureCell:(UITableViewCell *)cell
          withGear:(Gear *)gear
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    UILabel *textLabel = [cell viewWithTag:1];
    UILabel *detailTextLabel = [cell viewWithTag:2];
    UIImageView *imageView = [cell viewWithTag:3];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    textLabel.text = gear.text;
    detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    detailTextLabel.text = gear.notes;
    [self.sharedManager setImage:[NSString stringWithFormat:@"shop_%@", gear.key]
                      withFormat:@"png"
                          onView:imageView];

    UILabel *equippedLabel = [cell viewWithTag:4];
    equippedLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    equippedLabel.textAlignment = NSTextAlignmentRight;
    if ([self.equipType isEqualToString:@"equipped"]) {
        if ([gear isEquippedBy:self.user]) {
            equippedLabel.text = NSLocalizedString(@"equipped", nil);
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            self.equippedIndex = indexPath;
        } else {
            equippedLabel.text = nil;
            cell.backgroundColor = [UIColor whiteColor];
        }
    } else {
        if ([gear isCostumeOf:self.user]) {
            equippedLabel.text = NSLocalizedString(@"equipped", nil);
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            self.equippedIndex = indexPath;
        } else {
            equippedLabel.text = nil;
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];
    if (buttonIndex == 0) {
        __weak HRPGEquipmentDetailViewController *weakSelf = self;
        [self.sharedManager
            equipObject:selectedGear.key
               withType:self.equipType
              onSuccess:^() {
                  if (weakSelf.equippedIndex && (weakSelf.equippedIndex.item != selectedIndex.item ||
                                             weakSelf.equippedIndex.section != selectedIndex.section)) {
                      [weakSelf.tableView reloadRowsAtIndexPaths:@[ selectedIndex, weakSelf.equippedIndex ]
                                            withRowAnimation:UITableViewRowAnimationFade];
                  } else {
                      [weakSelf.tableView reloadRowsAtIndexPaths:@[ selectedIndex ]
                                            withRowAnimation:UITableViewRowAnimationFade];
                  }
                  if ([weakSelf.equipType isEqualToString:@"equipped"]) {
                      if ([selectedGear isEquippedBy:weakSelf.user]) {
                          weakSelf.equippedIndex = selectedIndex;
                      } else {
                          weakSelf.equippedIndex = nil;
                      }
                  } else {
                      if ([selectedGear isCostumeOf:weakSelf.user]) {
                          weakSelf.equippedIndex = selectedIndex;
                      } else {
                          weakSelf.equippedIndex = nil;
                      }
                  }
              }
                onError:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];
}

@end
