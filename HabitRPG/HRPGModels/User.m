//
//  User.m
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "User.h"
#import "HRPGAppDelegate.h"
#import "Customization.h"
#import <CommonCrypto/CommonCrypto.h>

@interface User ()
@property (nonatomic) NSDate *lastImageGeneration;
@end

@implementation User

@dynamic armoireEnabled;
@dynamic armoireEmpty;
@dynamic acceptedCommunityGuidelines;
@dynamic background;
@dynamic balance;
@dynamic blurb;
@dynamic contributorLevel;
@dynamic contributorText;
@dynamic costumeArmor;
@dynamic costumeBack;
@dynamic costumeBody;
@dynamic costumeEyewear;
@dynamic costumeHead;
@dynamic costumeHeadAccessory;
@dynamic costumeShield;
@dynamic costumeWeapon;
@dynamic currentMount;
@dynamic currentPet;
@dynamic dayStart;
@dynamic disableClass;
@dynamic dropsEnabled;
@dynamic equippedArmor;
@dynamic equippedBack;
@dynamic equippedBody;
@dynamic equippedEyewear;
@dynamic equippedHead;
@dynamic equippedHeadAccessory;
@dynamic equippedShield;
@dynamic equippedWeapon;
@dynamic experience;
@dynamic gold;
@dynamic hairBangs;
@dynamic hairBase;
@dynamic hairBeard;
@dynamic hairColor;
@dynamic hairMustache;
@dynamic hairFlower;
@dynamic hclass;
@dynamic health;
@dynamic id;
@dynamic itemsEnabled;
@dynamic level;
@dynamic magic;
@dynamic maxHealth;
@dynamic maxMagic;
@dynamic memberSince;
@dynamic nextLevel;
@dynamic habitNewStuff;
@dynamic participateInQuest;
@dynamic shirt;
@dynamic size;
@dynamic skin;
@dynamic sleep;
@dynamic username;
@dynamic groups;
@dynamic ownedEggs;
@dynamic ownedFood;
@dynamic ownedGear;
@dynamic ownedHatchingPotions;
@dynamic ownedQuests;
@dynamic party;
@dynamic rewards;
@dynamic tags;
@dynamic tasks;
@dynamic lastLogin;
@dynamic lastAvatarFull;
@dynamic lastAvatarNoPet;
@dynamic lastAvatarHead;
@dynamic selectedClass;
@dynamic useCostume;
@dynamic partyOrder;
@dynamic partyPosition;
@synthesize petCount = _petCount;
@synthesize customizationsDictionary;
@synthesize lastImageGeneration;

- (void)setAvatarOnImageView:(UIImageView *)imageView useForce:(BOOL)force {
    [self setAvatarOnImageView:imageView withPetMount:YES onlyHead:NO withBackground:YES useForce:force];
}

- (void)setAvatarOnImageView:(UIImageView *)imageView withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead useForce:(BOOL)force {
    [self setAvatarOnImageView:imageView withPetMount:withPetMount onlyHead:onlyHead withBackground:NO useForce:force];
}

- (void)setAvatarOnImageView:(UIImageView *)imageView withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead withBackground:(BOOL)withBackground useForce:(BOOL)force {
    [self getAvatarImage:^(UIImage* image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    } withPetMount:withPetMount onlyHead:onlyHead withBackground:withBackground useForce:force];
}

- (void)getAvatarImage:(void (^)(UIImage *))successBlock withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead withBackground:(BOOL)withBackground useForce:(BOOL)force {
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *sharedManager = appdelegate.sharedManager;
    /*
    NSString *cachedImageName;
    UIImage *cachedImage;
    if (withPetMount && !onlyHead) {
        cachedImageName = [NSString stringWithFormat:@"%@_full", self.username];
    } else if (!withPetMount && !onlyHead) {
        cachedImageName = [NSString stringWithFormat:@"%@_noPetMount", self.username];
    } else {
        cachedImageName = [NSString stringWithFormat:@"%@_head", self.username];
    }
    cachedImage = [sharedManager getCachedImage:cachedImageName];
    if (cachedImage && ( !force || [[NSDate date] timeIntervalSinceDate:self.lastImageGeneration] < 2)) {
        if (withPetMount && !onlyHead && [self.lastLogin isEqualToDate:self.lastAvatarFull]) {
            successBlock(cachedImage);
            return;
        } else if (!withPetMount && !onlyHead && [self.lastLogin isEqualToDate:self.lastAvatarNoPet]) {
            successBlock(cachedImage);
            return;
        } else if ([self.lastLogin isEqualToDate:self.lastAvatarHead]) {
            successBlock(cachedImage);
            return;
        }
    }
    */
    if (self.skin == nil) {
        return;
    }
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:20];
    for (int i = 0; i <= 19; i++) {
        [imageArray addObject:[NSNull null]];
    }
    int currentLayer = 0;

    __block UIImage *background = nil;
    __block UIImage *currentPet = nil;
    __block UIImage *currentMount = nil;
    __block UIImage *currentMountHead = nil;
    dispatch_group_t group = dispatch_group_create();

    if (withBackground && self.background && self.background.length > 0) {
        dispatch_group_enter(group);
        [sharedManager getImage:[NSString stringWithFormat:@"background_%@", self.background] withFormat:nil onSuccess:^(UIImage *image) {
            background = image;
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    NSString *back = [self.useCostume boolValue] ? self.costumeBack : self.equippedBack;
    if (![back isEqualToString:@"back_base_0"] && back) {
        NSString *format = nil;
        dispatch_group_enter(group);
        currentLayer++; //bump up current layer to 1 for skin
        [sharedManager getImage:[NSString stringWithFormat:@"%@", back] withFormat:format onSuccess:^(UIImage *image) {
            // back accessory goes into layer 0, even though we incremented currentLayer
            [imageArray replaceObjectAtIndex:0 withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_enter(group);
    NSString *skinString = [NSString stringWithFormat:@"skin_%@", self.skin];
    if (self.sleep) {
        skinString = [skinString stringByAppendingString:@"_sleep"];
    }
    [sharedManager getImage:skinString withFormat:nil onSuccess:^(UIImage *image) {
        [imageArray replaceObjectAtIndex:currentLayer withObject:image];
        dispatch_group_leave(group);
    } onError:^() {
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    currentLayer++;
    [sharedManager getImage:[NSString stringWithFormat:@"%@_shirt_%@", self.size, self.shirt] withFormat:nil onSuccess:^(UIImage *image){
        [imageArray replaceObjectAtIndex:currentLayer withObject:image];
        dispatch_group_leave(group);
    } onError:^() {
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    currentLayer++;
    [sharedManager getImage:[NSString stringWithFormat:@"head_0"] withFormat:nil onSuccess:^(UIImage *image) {
        [imageArray replaceObjectAtIndex:currentLayer withObject:image];
        dispatch_group_leave(group);
    } onError:^() {
        dispatch_group_leave(group);
    }];

    NSString *armor = [self.useCostume boolValue] ? self.costumeArmor : self.equippedArmor;
    if (![armor isEqualToString:@"armor_base_0"] && armor) {
        NSString *format = nil;
        if ([armor isEqualToString:@"armor_special_0"] || [armor isEqualToString:@"armor_special_1"]) {
            format = @"gif";
        }
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"%@_%@", self.size, armor] withFormat:format onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    NSString *body = [self.useCostume boolValue] ? self.costumeBody : self.equippedBody;
    if (![body isEqualToString:@"body_base_0"] && body) {
        NSString *format = nil;
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"%@", body] withFormat:format onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    if ([self.hairBase integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_base_%@_%@", self.hairBase, self.hairColor] withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }


    if ([self.hairBangs integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_bangs_%@_%@", self.hairBangs, self.hairColor] withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    if ([self.hairMustache integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_mustache_%@_%@", self.hairMustache, self.hairColor] withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    if ([self.hairBeard integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_beard_%@_%@", self.hairBeard, self.hairColor] withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    NSString *eyewear = [self.useCostume boolValue] ? self.costumeEyewear : self.equippedEyewear;
    if (![eyewear isEqualToString:@"eyewear_base_0"] && eyewear) {
        NSString *format = nil;
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"%@", eyewear] withFormat:format onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    NSString *head = [self.useCostume boolValue] ? self.costumeHead : self.equippedHead;
    if (![head isEqualToString:@"head_base_0"] && head) {
        NSString *format = nil;
        if ([head isEqualToString:@"head_special_0"] || [head isEqualToString:@"head_special_1"]) {
            format = @"gif";
        }
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:head withFormat:format onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    NSString *headAccessory = [self.useCostume boolValue] ? self.costumeHeadAccessory : self.equippedHeadAccessory;
    if (headAccessory && ![headAccessory isEqualToString:@"headAccessory_base_0"] && headAccessory) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:headAccessory withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    if ([self.hairFlower integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_flower_%@", self.hairFlower] withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    
    NSString *shield = [self.useCostume boolValue] ? self.costumeShield : self.equippedShield;
    if (!onlyHead && ![shield isEqualToString:@"shield_base_0"] && shield) {
        NSString *format = nil;
        if ([shield isEqualToString:@"shield_special_0"]) {
            format = @"gif";
        }
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:shield withFormat:format onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }
    NSString *weapon = [self.useCostume boolValue] ? self.costumeWeapon : self.equippedWeapon;
    if (!onlyHead && ![weapon isEqualToString:@"weapon_base_0"] && weapon) {
        NSString *format = nil;
        if ([weapon isEqualToString:@"weapon_special_0"] || [weapon isEqualToString:@"weapon_special_critical"]) {
            format = @"gif";
        }
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:weapon withFormat:format onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    if (self.sleep) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:@"zzz" withFormat:nil onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    if (withPetMount && self.currentPet && self.currentPet.length > 0) {
        dispatch_group_enter(group);
        currentLayer++;
        NSString *format = nil;
        if ([self.currentPet isEqualToString:@"Wolf-Cerberus"]) {
            format = @"gif";
        }
        [sharedManager getImage:[NSString stringWithFormat:@"Pet-%@", self.currentPet] withFormat:format onSuccess:^(UIImage *image) {
            currentPet = image;
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    if (withPetMount && self.currentMount && self.currentMount.length > 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"Mount_Head_%@", self.currentMount] withFormat:nil onSuccess:^(UIImage *image) {
            currentMountHead = image;
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    if (withPetMount && self.currentMount && self.currentMount.length > 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"Mount_Body_%@", self.currentMount] withFormat:nil onSuccess:^(UIImage *image) {
            currentMount = image;
            dispatch_group_leave(group);
        } onError:^() {
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int yoffset = 18;
        int xoffset = 25;
        float width = 140.0f;
        float height = 147.0f;
        if (!withPetMount) {
            xoffset = 0;
            width = 90.0f;
            height = 90.0f;
            yoffset = 0;
        }
        if (onlyHead) {
            xoffset = -29.0f;
            width = 55.0f;
            height = 55.0f;
            yoffset = -6.0f;
        }

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0f);
        
        if (withBackground && self.background && self.background.length > 0) {
            [background drawInRect:CGRectMake(0, 0, background.size.width, background.size.height)];
        }
        
        if (withPetMount && self.currentMount && self.currentMount.length > 0) {
            yoffset = 0;
            [currentMount drawInRect:CGRectMake(25, 18, currentMount.size.width, currentMount.size.height)];
        }
        for (id item in imageArray) {
            if (item != [NSNull null]) {
                UIImage *addImage = (UIImage *) item;
                [addImage drawInRect:CGRectMake(xoffset, yoffset, addImage.size.width, addImage.size.height)];
            }
        }
        if (withPetMount && self.currentMount && self.currentMount.length > 0) {
            [currentMountHead drawInRect:CGRectMake(25, 18, currentMountHead.size.width, currentMountHead.size.height)];
        }
        if (withPetMount && self.currentPet) {
            [currentPet drawInRect:CGRectMake(0, 43, currentPet.size.width, currentPet.size.height)];
        }

        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        successBlock(resultImage);
        /*[sharedManager setCachedImage:resultImage withName:cachedImageName onSuccess:^() {
            if (withPetMount && !onlyHead) {
                self.lastAvatarFull = [self.lastLogin copy];
            } else if (!withPetMount && !onlyHead) {
                self.lastAvatarNoPet = [self.lastLogin copy];
            } else {
                self.lastAvatarHead = [self.lastLogin copy];
            }
            self.lastImageGeneration = [NSDate date];
        }];*/
    });
}

-(UIColor *)classColor {
    if ([self.hclass isEqualToString:@"warrior"]) {
        return [UIColor colorWithRed:0.792 green:0.267 blue:0.239 alpha:1.000];
    } else if ([self.hclass isEqualToString:@"mage"]) {
        return [UIColor colorWithRed:0.211 green:0.718 blue:0.168 alpha:1.000];
    } else if ([self.hclass isEqualToString:@"rogue"]) {
        return [UIColor colorWithRed:0.177 green:0.333 blue:0.559 alpha:1.000];
    } else if ([self.hclass isEqualToString:@"healer"]) {
        return [UIColor colorWithRed:0.304 green:0.702 blue:0.839 alpha:1.000];
    } else {
        return [UIColor blackColor];
    }
}

-(UIColor *)contributorColor {
    if ([self.contributorLevel integerValue] == 1) {
        return [UIColor colorWithRed:0.941 green:0.380 blue:0.549 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 2) {
        return [UIColor colorWithRed:0.659 green:0.118 blue:0.141 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 3) {
        return [UIColor colorWithRed:0.984 green:0.098 blue:0.031 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 4) {
        return [UIColor colorWithRed:0.992 green:0.506 blue:0.031 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 5) {
        return [UIColor colorWithRed:0.806 green:0.779 blue:0.284 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 6) {
        return [UIColor colorWithRed:0.333 green:1.000 blue:0.035 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 7) {
        return [UIColor colorWithRed:0.071 green:0.592 blue:1.000 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 8) {
        return [UIColor colorWithRed:0.055 green:0.000 blue:0.876 alpha:1.000];
    } else if ([self.contributorLevel integerValue] == 9) {
        return [UIColor colorWithRed:0.455 green:0.000 blue:0.486 alpha:1.000];
    }
    return [UIColor grayColor];
}

- (void)setPetCountFromArray:(NSArray *)petArray {
    _petCount = [NSNumber numberWithInt:(int)[petArray count]];
}

- (void)setCustomizationsDictionary:(NSDictionary *)customizationDictionary {
    if (customizationDictionary.count == 0) {
        return;
    }
    NSMutableDictionary *dict  = [customizationDictionary mutableCopy];

    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.sharedManager.getManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *customizations = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Customization *customization in customizations) {
        if ([customization.type isEqualToString:@"hair"]) {
            NSNumber *purchased = dict[customization.type][customization.group][customization.name];
            if (purchased) {
                customization.purchased = purchased;
                NSMutableDictionary *typeDict = [dict[customization.type] mutableCopy];
                NSMutableDictionary *groupDict = [typeDict[customization.group] mutableCopy];
                [groupDict removeObjectForKey:customization.name];
                typeDict[customization.group] = groupDict;
                dict[customization.type] = typeDict;
            }
        } else {
            NSNumber *purchased = dict[customization.type][customization.name];
            if (purchased) {
                customization.purchased = purchased;
                NSMutableDictionary *typeDict = [dict[customization.type] mutableCopy];
                [typeDict removeObjectForKey:customization.name];
                dict[customization.type] = typeDict;
            }
        }
    }
    
    for (NSString *type in @[@"background", @"shirt", @"skin"]) {
        for (NSString *key in dict[type]) {
            Customization *customization = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"Customization"
                                            inManagedObjectContext:managedObjectContext];
            customization.name = key;
            customization.type = type;
            customization.purchased = dict[type][key];
            [managedObjectContext save:&error];
        }
    }
    
    for (NSString *group in @[@"color", @"bangs", @"beard", @"mustache"]) {
        for (NSString *key in dict[@"hair"][group]) {
            Customization *customization = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"Customization"
                                            inManagedObjectContext:managedObjectContext];
            customization.name = key;
            customization.type = @"hair";
            customization.group = group;
            customization.purchased = dict[@"hair"][group][key];
            [managedObjectContext save:&error];
        }
    }


}

- (NSArray*) equippedArray {
    NSMutableArray *array = [NSMutableArray array];
    if (self.equippedArmor) {
        [array addObject:self.equippedArmor];
    }
    if (self.equippedBack) {
        [array addObject:self.equippedBack];
    }
    if (self.equippedHead) {
        [array addObject:self.equippedHead];
    }
    if (self.equippedHeadAccessory) {
        [array addObject:self.equippedHeadAccessory];
    }
    if (self.equippedShield) {
        [array addObject:self.equippedShield];
    }
    if (self.equippedWeapon) {
        [array addObject:self.equippedWeapon];
    }
    
    if (self.costumeArmor) {
        [array addObject:self.costumeArmor];
    }
    if (self.costumeBack) {
        [array addObject:self.costumeBack];
    }
    if (self.costumeHead) {
        [array addObject:self.costumeHead];
    }
    if (self.costumeHeadAccessory) {
        [array addObject:self.costumeHeadAccessory];
    }
    if (self.costumeShield) {
        [array addObject:self.costumeShield];
    }
    if (self.costumeWeapon) {
        [array addObject:self.costumeWeapon];
    }
    
    return array;
}

- (NSString *)getCleanedClassName {
    NSString *className = [self valueForKey:@"hclass"];
    if ([className isEqualToString:@"wizard"]) {
        return @"mage";
    }
    return className;
}

- (NSString *)getDirtyClassName {
    return [self valueForKey:@"hclass"];
}

// Custom method to calculate the SHA-256 hash using Common Crypto
- (NSString *)hashedValueForAccountName {
    const int HASH_SIZE = 32;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [self.username UTF8String];
    size_t accountNameLen = strlen(accountName);
    
    // Confirm that the length of the user name is small enough
    // to be recast when calling the hash function.
    if (accountNameLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", self.username);
        return nil;
    }
    CC_SHA256(accountName, (CC_LONG)accountNameLen, hashedChars);
    
    // Convert the array of bytes into a string showing its hex representation.
    NSMutableString *userAccountHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }
    
    return userAccountHash;
}

@end
