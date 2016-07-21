//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGItemViewController.h"
#import "Egg.h"
#import "HRPGAppDelegate.h"
#import "HRPGImageOverlayView.h"
#import "HRPGSharingManager.h"
#import "HatchingPotion.h"
#import "Quest.h"
#import "HRPGCoreDataDataSource.h"

@interface HRPGItemViewController ()
@property Item *selectedItem;
@property NSIndexPath *selectedIndex;
@property BOOL isHatching;
@property NSArray *existingPets;
@property UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property HRPGCoreDataDataSource *dataSource;

@end

@implementation HRPGItemViewController

float textWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    
    self.tutorialIdentifier = @"items";

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    textWidth = screenRect.size.width - 118;

    [self clearFaultyItems];
    
    if (!self.itemType) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)setupTableView {
    __weak HRPGItemViewController *weakSelf = self;
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, Item *item, NSIndexPath *indexPath) {
        [weakSelf configureCell:cell withItem:item withAnimation:YES];
    };
    FetchRequestConfigureBlock configureFetchRequest = ^(NSFetchRequest *fetchRequest) {
        NSPredicate *predicate;
        if (self.itemType) {
            predicate = [NSPredicate predicateWithFormat:@"owned > 0 && text != '' && type == %@", weakSelf.itemType];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"owned > 0 && text != ''"];
        }
        [fetchRequest setPredicate:predicate];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
        NSArray *sortDescriptors = @[ typeDescriptor, indexDescriptor ];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
    };
    self.dataSource= [[HRPGCoreDataDataSource alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                       entityName:@"Item"
                                                                   cellIdentifier:@"Cell"
                                                               configureCellBlock:configureCell
                                                                fetchRequestBlock:configureFetchRequest
                                                                    asDelegateFor:self.tableView];
    self.dataSource.sectionNameKeyPath = @"type";
}

- (void)clearFaultyItems {
    //An issue with RestKit can cause items to accidentally be inserted twice.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"text == ''"];
    NSError *error;
    NSArray<Item *> *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (items.count > 0) {
        for (Item *item in items) {
            [self.managedObjectContext deleteObject:item];
        }
        NSError *error;
        [self.managedObjectContext save:&error];
        
        [self.sharedManager fetchUser:nil onError:nil];
    }
}

- (void)fetchExistingPetsWithPartName:(NSString *)string {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"key contains[cd] %@ && trained > 0", string];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    self.existingPets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)showCancelButton {
    self.backButton = self.navigationItem.leftBarButtonItem;
    UIBarButtonItem *cancelButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(endHatching)];
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
}

- (void)showBackButton {
    [self.navigationItem setLeftBarButtonItem:self.backButton animated:YES];
}

- (void)endHatching {
    [self showBackButton];
    self.isHatching = NO;
    self.itemType = nil;
    [self.dataSource reconfigureFetchRequest];
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"items"]) {
        return @{
            @"text" : NSLocalizedString(
                @"Earn items by completing tasks and leveling up. Tap on an item to use it!", nil)
        };
    }
    return nil;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.dataSource itemAtIndexPath:indexPath];
    NSInteger height = 24;
    height = height +
    [item.text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                            options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{
                                      NSFontAttributeName :
                                          [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                      }
                            context:nil]
    .size.height;
    
    if (height < 60) {
        return 60;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    Item *item = [self.dataSource itemAtIndexPath:indexPath];
    if (self.isHatching) {
        for (Pet *pet in self.existingPets) {
            if ([pet.key rangeOfString:item.key].location != NSNotFound) {
                return;
            }
        }
        NSString *eggName;
        NSString *eggDisplayName;
        NSString *potionName;
        NSString *potionDisplayName;
        if ([self.selectedItem isKindOfClass:[HatchingPotion class]]) {
            eggName = item.key;
            eggDisplayName = item.text;
            potionName = self.selectedItem.key;
            potionDisplayName = self.selectedItem.text;
        } else {
            eggName = self.selectedItem.key;
            eggDisplayName = self.selectedItem.text;
            potionName = item.key;
            potionDisplayName = item.text;
        }
        [self.sharedManager
              hatchEgg:eggName
            withPotion:potionName
             onSuccess:^(NSString *message) {
                 [self.sharedManager
                       getImage:[NSString stringWithFormat:@"Pet-%@-%@", eggName, potionName]
                     withFormat:nil
                      onSuccess:^(UIImage *image) {
                          NSArray *nibViews =
                              [[NSBundle mainBundle] loadNibNamed:@"HRPGImageOverlayView"
                                                            owner:self
                                                          options:nil];
                          HRPGImageOverlayView *overlayView = nibViews[0];
                          [overlayView displayImage:image];
                          overlayView.imageWidth = 81;
                          overlayView.imageHeight = 99;
                          overlayView.descriptionText = [NSString
                              stringWithFormat:NSLocalizedString(@"You hatched a %@ %@!", nil),
                                               potionDisplayName, eggDisplayName];
                          overlayView.dismissButtonText = NSLocalizedString(@"Close", nil);
                          overlayView.shareAction = ^() {
                              HRPGAppDelegate *del =
                                  (HRPGAppDelegate *)[UIApplication sharedApplication].delegate;
                              UIViewController *activeViewController =
                                  del.window.rootViewController.presentedViewController;
                              [HRPGSharingManager shareItems:@[
                                  [[NSString stringWithFormat:NSLocalizedString(
                                                                  @"I just hatched a %@ %@ pet in "
                                                                  @"Habitica by completing my "
                                                                  @"real-life tasks!",
                                                                  nil),
                                                              potionDisplayName, eggDisplayName]
                                      stringByAppendingString:
                                          @" https://habitica.com/social/hatch-pet"],
                                  image
                              ]
                                withPresentingViewController:activeViewController withSourceView:[self.tableView cellForRowAtIndexPath:indexPath]];
                          };
                          [overlayView sizeToFit];
                          KLCPopup *popup =
                              [KLCPopup popupWithContentView:overlayView
                                                    showType:KLCPopupShowTypeBounceIn
                                                 dismissType:KLCPopupDismissTypeBounceOut
                                                    maskType:KLCPopupMaskTypeDimmed
                                    dismissOnBackgroundTouch:YES
                                       dismissOnContentTouch:YES];
                          [popup show];
                          if (self.shouldDismissAfterAction) {
                              [self dismissViewControllerAnimated:YES completion:nil];
                          }
                      }
                        onError:nil];
             }
               onError:nil];

        [self endHatching];
        return;
    }
    NSString *extraItem;
    NSString *destructiveButton =
        [NSString stringWithFormat:NSLocalizedString(@"Sell (%@ Gold)", nil), item.value];
    if ([item isKindOfClass:[Quest class]]) {
        extraItem = NSLocalizedString(@"Invite Party", nil);
        destructiveButton = nil;
    } else if ([item isKindOfClass:[HatchingPotion class]]) {
        extraItem = NSLocalizedString(@"Hatch Egg", nil);
    } else if ([item isKindOfClass:[Egg class]]) {
        extraItem = NSLocalizedString(@"Hatch with Potion", nil);
    }

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:destructiveButton
                                              otherButtonTitles:extraItem, nil];
    popup.tag = 1;
    self.selectedItem = item;

    // get the selected cell so that the popup can be displayed near it on the iPad
    UITableViewCell *selectedCell = [self.dataSource cellAtIndexPath:indexPath];

    CGRect rectIPad = CGRectMake(selectedCell.frame.origin.x, selectedCell.frame.origin.y,
                                 selectedCell.frame.size.width, selectedCell.frame.size.height);
    // using the following form rather than [popup showInView:[UIApplication
    // sharedApplication].keyWindow]] to make it compatible with both iPhone and iPad
    [popup showFromRect:rectIPad inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.sharedManager sellItem:self.selectedItem onSuccess:nil onError:nil];
    } else if (buttonIndex == 0 && [self.selectedItem isKindOfClass:[Quest class]]) {
        User *user = [self.sharedManager getUser];
        Quest *quest = (Quest *)self.selectedItem;
        [self.sharedManager inviteToQuest:user.partyID withQuest:quest onSuccess:^() {
            if (self.shouldDismissAfterAction) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }onError:nil];
    } else if (buttonIndex == 1 && ![self.selectedItem isKindOfClass:[Quest class]]) {
        self.isHatching = YES;
        if ([self.selectedItem isKindOfClass:[HatchingPotion class]]) {
            self.itemType = @"eggs";
        } else if ([self.selectedItem isKindOfClass:[Egg class]]) {
            self.itemType = @"hatchingPotions";
        }
        [self.dataSource reconfigureFetchRequest];
        [self fetchExistingPetsWithPartName:self.selectedItem.key];
        [self showCancelButton];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell
          withItem:(Item *)item
        withAnimation:(BOOL)animate {
    UILabel *textLabel = [cell viewWithTag:1];
    textLabel.text = item.text;
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UILabel *detailTextLabel = [cell viewWithTag:2];
    detailTextLabel.text = [NSString stringWithFormat:@"%@", item.owned];
    detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [detailTextLabel sizeToFit];
    NSString *imageName;
    if ([item.type isEqualToString:@"quests"]) {
        imageName = @"inventory_quest_scroll";
    } else {
        NSString *type;
        if ([item.type isEqualToString:@"eggs"]) {
            type = @"Egg";
        } else if ([item.type isEqualToString:@"food"]) {
            type = @"Food";
        } else if ([item.type isEqualToString:@"hatchingPotions"]) {
            type = @"HatchingPotion";
        }
        imageName = [NSString stringWithFormat:@"Pet_%@_%@", type, item.key];
    }
    [self.sharedManager setImage:imageName withFormat:@"png" onView:cell.imageView];
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.alpha = 1;
    textLabel.alpha = 1;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (self.isHatching) {
        for (Pet *pet in self.existingPets) {
            if ([pet.key rangeOfString:item.key].location != NSNotFound) {
                cell.imageView.alpha = 0.4;
                textLabel.alpha = 0.4;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            }
        }
    }
}

@end
