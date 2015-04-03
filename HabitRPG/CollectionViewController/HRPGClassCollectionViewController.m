//
//  HRPGClassCollectionViewController.m
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGClassCollectionViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "HRPGTopHeaderNavigationController.h"
#import "User.h"
#import "HRPGWebViewController.h"

@interface HRPGClassCollectionViewController ()
@property CGSize screenSize;
@property NSArray *classesArray;
@property User *user;
@property (nonatomic) HRPGManager *sharedManager;
@end

@implementation HRPGClassCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = self.sharedManager.getManagedObjectContext;
    self.user = [self.sharedManager getUser];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
        [self.collectionView setContentInset:UIEdgeInsetsMake([navigationController getContentOffset],0,0,0)];
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([navigationController getContentOffset],0,0,0);
    }
    
    [self loadClassesArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSArray *item = [self.classesArray objectAtIndex:indexPath.item];
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
    
    label.text = [item objectAtIndex:0];
    User *classUser = [item objectAtIndex:1];
    
    [classUser setAvatarOnImageView:imageView withPetMount:YES onlyHead:NO useForce:NO];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.screenSize.width/2-0.5, 170);
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HelpSegue"]) {
        HRPGWebViewController *webViewController = (HRPGWebViewController*)segue.destinationViewController;
        webViewController.url = @"http://habitrpg.wikia.com/wiki/Class_System";
    }
}

- (void)loadClassesArray {
    User *warrior = [self setUpClassUserWithClass:@"Warrior"];
    warrior.equippedArmor = @"armor_warrior_5";
    warrior.equippedHead = @"head_warrior_5";
    warrior.equippedShield = @"shield_warrior_5";
    warrior.equippedWeapon = @"weapon_warrior_6";
    User *mage = [self setUpClassUserWithClass:@"Mage"];
    mage.equippedArmor = @"armor_wizard_5";
    mage.equippedHead = @"head_wizard_5";
    mage.equippedWeapon = @"weapon_wizard_6";
    User *rogue = [self setUpClassUserWithClass:@"Rogue"];
    rogue.equippedArmor = @"armor_rogue_5";
    rogue.equippedHead = @"head_rogue_5";
    rogue.equippedShield = @"shield_rogue_6";
    rogue.equippedWeapon = @"weapon_rogue_6";
    User *healer = [self setUpClassUserWithClass:@"Healer"];
    healer.equippedArmor = @"armor_healer_5";
    healer.equippedHead = @"head_healer_5";
    healer.equippedShield = @"shield_healer_5";
    healer.equippedWeapon = @"weapon_healer_6";
    
    
    self.classesArray = @[
                          @[NSLocalizedString(@"Warrior", nil), warrior],
                          @[NSLocalizedString(@"Mage", nil), mage],
                          @[NSLocalizedString(@"Rogue", nil), rogue],
                          @[NSLocalizedString(@"Healer", nil), healer],
                          ];
}

- (User*)setUpClassUserWithClass:(NSString*)className {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    User *user = (User*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    user.username = [self.user.username stringByAppendingString:className];
    user.skin = self.user.skin;
    user.hairBangs = self.user.hairBangs;
    user.hairBase = self.user.hairBase;
    user.hairBeard = self.user.hairBeard;
    user.hairColor = self.user.hairColor;
    user.hairMustache = self.user.hairMustache;
    user.shirt = self.user.shirt;
    user.size = self.user.size;
    
    return user;
}

@end
