//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGItemViewController.h"
#import "Egg.h"
#import "HRPGAppDelegate.h"
#import "HRPGImageOverlayView.h"
#import "HRPGSharingManager.h"
#import "HatchingPotion.h"
#import "Quest+CoreDataClass.h"
#import "HRPGCoreDataDataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Habitica.h"
#import "HRPGShopViewController.h"
#import "Shop.h"
#import "Habitica-Swift.h"

@interface HRPGItemViewController ()
@property Item *selectedItem;
@property NSIndexPath *selectedIndex;
@property BOOL isHatching;
@property NSArray *existingPets;
@property UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property HRPGCoreDataDataSource *dataSource;

@property NSString *shopIdentifier;
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
        NSString *predicateString = @"owned > 0 && text != ''";
        
        if (![[HRPGManager sharedManager] getUser].subscriptionPlan.isActive) {
            predicateString = [predicateString stringByAppendingString:@" && (isSubscriberItem == nil || isSubscriberItem != YES)"];
        }
        
        if (self.itemType) {
            predicate = [NSPredicate predicateWithFormat:[predicateString stringByAppendingString:@" && type == %@"], weakSelf.itemType];
        } else {
            predicate = [NSPredicate predicateWithFormat:predicateString];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section+1 == [self.dataSource numberOfSections]) {
        return 180.0;
    } else {
        return [self.tableView sectionFooterHeight];
    }
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return false;
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section+1 == [self.dataSource numberOfSections]) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"ShopAdFooter" owner:self options:nil] lastObject];
        UIImageView *imageView = [view viewWithTag:1];
        UILabel *label = [view viewWithTag:2];
        UIButton *openShopButton = [view viewWithTag:3];
        
        openShopButton.layer.borderColor = [UIColor purple400].CGColor;
        openShopButton.layer.borderWidth = 1.0;
        openShopButton.layer.cornerRadius = 5;
        
        if (self.isHatching) {
            [[HRPGManager sharedManager] setImage:@"npc_alex" withFormat:nil onView:imageView];
            label.text = NSLocalizedString(@"Not getting the right drops? Check out the Market to buy just the things you need!", nil);
            [openShopButton addTarget:self action:@selector(openMarket:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [[HRPGManager sharedManager] setImage:@"npc_ian" withFormat:nil onView:imageView];
            label.text = NSLocalizedString(@"Looking for more adventures? Visit Ian to buy more quest scrolls!", nil);
            [openShopButton addTarget:self action:@selector(openQuestShop:) forControlEvents:UIControlEventTouchUpInside];
        }
        return view;
    } else {
        return nil;
    }
}

- (void)clearFaultyItems {
    //An issue with RestKit can cause items to accidentally be inserted twice.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSError *error;
    NSArray<Item *> *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray<Item *> *duplicateItems = [NSMutableArray arrayWithCapacity:items.count/2];
    
    for (int pos = 1; pos < items.count; pos++) {
        if ([items[pos].key isEqualToString:items[pos-1].key]) {
            [duplicateItems addObject:items[pos]];
        }
    }
    
    if (duplicateItems.count > 0) {
        for (Item *item in items) {
            [self.managedObjectContext deleteObject:item];
        }
        NSError *error;
        [self.managedObjectContext save:&error];
        
        [[HRPGManager sharedManager] fetchUser:nil onError:nil];
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
        [[HRPGManager sharedManager]
              hatchEgg:eggName
            withPotion:potionName
             onSuccess:^(NSString *message) {
                 [[HRPGManager sharedManager]
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
    } else if ([item.key isEqualToString:@"inventory_present"]) {
        extraItem = NSLocalizedString(@"Open", nil);
        destructiveButton = nil;
    } else if ([item.key isEqualToString:@"Saddle"]){
        destructiveButton = nil;
    }
    self.selectedItem = item;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction cancelActionWithHandler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    }]];
    if (destructiveButton != nil) {
        [alertController addAction:[UIAlertAction actionWithTitle:destructiveButton style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:true];
[[HRPGManager sharedManager] sellItem:self.selectedItem onSuccess:nil onError:nil];
        }]];
    }
    if (extraItem) {
    [alertController addAction:[UIAlertAction actionWithTitle:extraItem style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        if ([self.selectedItem isKindOfClass:[Quest class]]) {
            User *user = [[HRPGManager sharedManager] getUser];
            Quest *quest = (Quest *)self.selectedItem;
            [[HRPGManager sharedManager] inviteToQuest:user.partyID withQuest:quest onSuccess:^() {
                if (self.shouldDismissAfterAction) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }onError:nil];
        } else if ([self.selectedItem.key isEqualToString:@"inventory_present"]) {
            [[HRPGManager sharedManager] openMysteryItem:nil onError:nil];
        } else if (![self.selectedItem isKindOfClass:[Quest class]]) {
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
    }]];
    }
    
    if (alertController.actions.count > 1) {
        UITableViewCell *selectedCell = [self.dataSource cellAtIndexPath:indexPath];
        alertController.popoverPresentationController.sourceView = selectedCell;
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)actionSheetClickedButtonAtIndex:(NSInteger)buttonIndex {
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
    } else if ([item.key isEqualToString:@"inventory_present"]) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]];
        imageName = [NSString stringWithFormat:@"inventory_present_%02ld", (long)[components month]];
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
    [[HRPGManager sharedManager] setImage:imageName withFormat:@"png" onView:cell.imageView];
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

- (void)openQuestShop:(UIButton *)button {
    self.shopIdentifier = QuestsShopKey;
    [self performSegueWithIdentifier:@"ShowShopSegue" sender:self];
}

- (void)openMarket:(UIButton *)button {
    self.shopIdentifier = MarketKey;
    [self performSegueWithIdentifier:@"ShowShopSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowShopSegue"]) {
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = self.shopIdentifier;
    }
}

@end
