//
//  User.m
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "User.h"
#import "HRPGAppDelegate.h"


@implementation User

@dynamic costumeArmor;
@dynamic costumeBack;
@dynamic costumeHead;
@dynamic costumeHeadAccessory;
@dynamic costumeShield;
@dynamic costumeWeapon;
@dynamic currentMount;
@dynamic currentPet;
@dynamic dayStart;
@dynamic equippedArmor;
@dynamic equippedBack;
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
@dynamic hclass;
@dynamic health;
@dynamic id;
@dynamic level;
@dynamic magic;
@dynamic maxHealth;
@dynamic maxMagic;
@dynamic nextLevel;
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
@dynamic useCostume;

- (void)setAvatarOnImageView:(UIImageView *)imageView {
    [self setAvatarOnImageView:imageView withPetMount:YES onlyHead:NO];
}

- (void)setAvatarOnImageView:(UIImageView *)imageView withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead{
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    HRPGManager *sharedManager = appdelegate.sharedManager;
    NSString *cachedImageName;
    UIImage *cachedImage;
    if (withPetMount && !onlyHead) {
        cachedImageName = [NSString stringWithFormat:@"%@_full", self.username];
    } else if (!withPetMount && !onlyHead){
        cachedImageName = [NSString stringWithFormat:@"%@_noPetMount", self.username];
    } else {
        cachedImageName = [NSString stringWithFormat:@"%@_head", self.username];
    }
    cachedImage = [sharedManager getCachedImage:cachedImageName];
    imageView.image = cachedImage;
    if (withPetMount && !onlyHead && [self.lastLogin isEqualToDate:self.lastAvatarFull]) {
        return;
    } else if (!withPetMount && !onlyHead && [self.lastLogin isEqualToDate:self.lastAvatarNoPet]){
        return;
    } else if ([self.lastLogin isEqualToDate:self.lastAvatarHead]){
        return;
    }
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:16];
    for(int i = 0; i<=16; i++) {
        [imageArray addObject:[NSNull null]];
    }
    int currentLayer = 0;
    
    __block UIImage *currentPet = nil;
    __block UIImage *currentMount = nil;
    __block UIImage *currentMountHead = nil;
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [sharedManager getImage:[NSString stringWithFormat:@"skin_%@", self.skin] onSuccess:^(UIImage *image) {
        [imageArray replaceObjectAtIndex:currentLayer withObject:image];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    currentLayer++;
    [sharedManager getImage:[NSString stringWithFormat:@"%@_shirt_%@", self.size, self.shirt] onSuccess:^(UIImage *image){
        [imageArray replaceObjectAtIndex:currentLayer withObject:image];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    currentLayer++;
    [sharedManager getImage:[NSString stringWithFormat:@"head_0"] onSuccess:^(UIImage *image) {
        [imageArray replaceObjectAtIndex:currentLayer withObject:image];
        dispatch_group_leave(group);
    }];
    NSString *armor = [self.useCostume boolValue] ? self.costumeArmor : self.equippedArmor;
    if (![armor isEqualToString:@"armor_base_0"]) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"%@_%@", self.size, armor] onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    
    if ([self.hairBase integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_base_%@_%@", self.hairBase, self.hairColor] onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }

    
    if ([self.hairBangs integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_bangs_%@_%@", self.hairBangs, self.hairColor] onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    
    if ([self.hairMustache integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_mustache_%@_%@", self.hairMustache, self.hairColor] onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
    }];
    }
        
    if ([self.hairBeard integerValue] != 0) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"hair_beard_%@_%@", self.hairBeard, self.hairColor] onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    
    NSString *head = [self.useCostume boolValue] ? self.costumeHead : self.equippedHead;
    if (![head isEqualToString:@"head_base_0"]) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:head onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    NSString *headAccessory = [self.useCostume boolValue] ? self.costumeHeadAccessory : self.equippedHeadAccessory;
    if (headAccessory && ![headAccessory isEqualToString:@"headAccessory_base_0"]) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:headAccessory onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    NSString *shield = [self.useCostume boolValue] ? self.costumeShield : self.equippedShield;
    if (!onlyHead && ![shield isEqualToString:@"shield_base_0"]) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:shield onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    NSString *weapon = [self.useCostume boolValue] ? self.costumeWeapon : self.equippedWeapon;
    if (!onlyHead && ![weapon isEqualToString:@"weapon_base_0"]) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:weapon onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    
    if (self.sleep) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:@"zzz" onSuccess:^(UIImage *image) {
            [imageArray replaceObjectAtIndex:currentLayer withObject:image];
            dispatch_group_leave(group);
        }];
    }
    
    if (withPetMount && self.currentPet) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"Pet-%@", self.currentPet] onSuccess:^(UIImage *image) {
            currentPet = image;
            dispatch_group_leave(group);
        }];
    }
    
    if (withPetMount && self.currentMount) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"Mount_Head_%@", self.currentMount] onSuccess:^(UIImage *image) {
            currentMountHead = image;
            dispatch_group_leave(group);
        }];
    }
    
    if (withPetMount && self.currentMount) {
        dispatch_group_enter(group);
        currentLayer++;
        [sharedManager getImage:[NSString stringWithFormat:@"Mount_Body_%@", self.currentMount] onSuccess:^(UIImage *image) {
            currentMount = image;
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
        if (withPetMount && self.currentMount) {
            yoffset = 0;
            [currentMount drawInRect:CGRectMake(25, 18, currentMount.size.width, currentMount.size.height)];
        }
        for (id item in imageArray) {
            if (item != [NSNull null]) {
                UIImage *addImage = (UIImage*)item;
                [addImage drawInRect:CGRectMake(xoffset, yoffset, addImage.size.width, addImage.size.height)];
            }
        }
        if (withPetMount && self.currentMount) {
            [currentMountHead drawInRect:CGRectMake(25, 18, currentMountHead.size.width, currentMountHead.size.height)];
        }
        if (self.currentPet) {
            [currentPet drawInRect:CGRectMake(0, 43, currentPet.size.width, currentPet.size.height)];
        }
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = resultImage;
        });
        [sharedManager setCachedImage:resultImage withName:cachedImageName onSuccess:^() {
            if (withPetMount && !onlyHead) {
                self.lastAvatarFull = [self.lastLogin copy];
            } else if (!withPetMount && !onlyHead){
                self.lastAvatarNoPet = [self.lastLogin copy];
            } else {
                self.lastAvatarHead = [self.lastLogin copy];
            }
        }];
    });
}

@end
