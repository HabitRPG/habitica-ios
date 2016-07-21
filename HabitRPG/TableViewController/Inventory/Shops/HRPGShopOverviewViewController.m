//
//  HRPGShopOverviewViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 11/07/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "HRPGShopOverviewViewController.h"
#import "HRPGShopViewController.h"
#import "Shop.h"
#import "NSString+StripHTML.h"

@interface HRPGShopOverviewViewController ()

@property NSMutableDictionary *shopDictionary;

@end

@implementation HRPGShopOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShopDictionary];
}

- (void)setupShopDictionary {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shop"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *shops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (shops) {
        self.shopDictionary = [NSMutableDictionary dictionaryWithCapacity:shops.count];
        for (Shop *shop in shops) {
            [self.shopDictionary setObject:shop forKey:shop.identifier];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *titleLabel = [cell viewWithTag:2];
    UILabel *descriptionLabel = [cell viewWithTag:3];
    
    Shop *shop = self.shopDictionary[[self identifierAtIndex:indexPath.item]];
    if (shop) {
        [self.sharedManager setImage:shop.imageName withFormat:nil onView:imageView];
        titleLabel.text = shop.text;
        descriptionLabel.text = [shop.notes stringByStrippingHTML];
    } else {
        switch (indexPath.item) {
            case 0: {
                [self.sharedManager setImage:@"npc_alex" withFormat:@"png" onView:imageView];
                titleLabel.text = NSLocalizedString(@"Market", nil);
                break;
            }
            case 1: {
                [self.sharedManager setImage:@"npc_ian" withFormat:@"png" onView:imageView];
                titleLabel.text = NSLocalizedString(@"Quests", nil);
                break;
            }
            case 2: {
                [self.sharedManager setImage:@"npc_timetravelers_active" withFormat:@"png" onView:imageView];
                titleLabel.text = NSLocalizedString(@"Time Travelers", nil);
                descriptionLabel.text = NSLocalizedString(@"", nil);
                break;
            }
            case 3: {
                [self.sharedManager setImage:@"seasonalshop_open" withFormat:@"png" onView:imageView];
                titleLabel.text = NSLocalizedString(@"Seasonal Shop", nil);
                descriptionLabel.text = NSLocalizedString(@"", nil);
                break;
            }
        }
        __weak HRPGShopOverviewViewController *weakSelf = self;
        [self.sharedManager fetchShopInventory:[self identifierAtIndex:indexPath.item] onSuccess:^{
            [weakSelf setupShopDictionary];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } onError:nil];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Shop *shop = self.shopDictionary[[self identifierAtIndex:indexPath.item]];
    float height = 60.0f;
    float width = self.viewWidth - 127;
    height = height +
    [shop.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{
                                          NSFontAttributeName : [UIFont
                                                                 preferredFontForTextStyle:UIFontTextStyleHeadline]
                                          }
                                context:nil]
    .size.height;
    if ([[shop.notes stringByStrippingHTML] length] > 0) {
        NSInteger notesHeight =
        [[shop.notes stringByStrippingHTML]
         boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{
                      NSFontAttributeName :
                          [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                      }
         context:nil]
        .size.height;
        
        if (notesHeight <
            [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].lineHeight * 5) {
            height = height + notesHeight;
        } else {
            height =
            height + [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].lineHeight * 5;
        }
    }
    if (height < 138) {
        return 138;
    }
    return height;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShopSegue"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        HRPGShopViewController *shopViewController = segue.destinationViewController;
        shopViewController.shopIdentifier = [self identifierAtIndex:indexPath.item];
    }
}

- (NSString *)identifierAtIndex:(long)index {
    switch (index) {
        case 0:
            return MarketKey;
            break;
        case 1:
            return QuestsShopKey;
            break;
        case 2:
            return TimeTravelersShopKey;
            break;
        case 3:
            return SeasonalShopKey;
            break;
        default:
            return nil;
    }
}

@end
