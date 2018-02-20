//
//  User.m
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "User.h"
#import "HRPGManager.h"
#import "Customization.h"
#import <CommonCrypto/CommonCrypto.h>
#import "Customization.h"
#import "Flags.h"
#import "YYWebImage.h"
#import "Masonry.h"
#import "HRPGAppDelegate.h"
#import "TutorialSteps.h"
#import "UIColor+Habitica.h"

@interface User ()
@property(nonatomic) NSDate *lastImageGeneration;
@end

@implementation User

@dynamic balance;
@dynamic blurb;
@dynamic strength;
@dynamic intelligence;
@dynamic constitution;
@dynamic perception;
@dynamic contributorLevel;
@dynamic contributorText;
@dynamic currentMount;
@dynamic currentPet;
@dynamic email;
@dynamic experience;
@dynamic gold;
@dynamic hclass;
@dynamic health;
@dynamic id;
@dynamic invitedParty;
@dynamic invitedPartyName;
@dynamic level;
@dynamic magic;
@dynamic maxHealth;
@dynamic maxMagic;
@dynamic memberSince;
@dynamic nextLevel;
@dynamic participateInQuest;
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
@dynamic partyOrder;
@dynamic partyPosition;
@dynamic partyID;
@dynamic pushDevices;
@dynamic inboxOptOut;
@dynamic inboxNewMessages;
@dynamic facebookID;
@dynamic googleID;
@dynamic subscriptionPlan;
@dynamic lastCron;
@dynamic needsCron;
@dynamic loginIncentives;
@dynamic pointsToAllocate;
@dynamic loginname;
@dynamic photoUrl;
@dynamic pendingDamage;

@synthesize petCount = _petCount;
@synthesize customizationsDictionary;
@synthesize lastImageGeneration;

@dynamic preferences;
@dynamic equipped;
@dynamic costume;
@dynamic flags;
@dynamic buff;
@dynamic specialItems;
@dynamic challenges;

+ (void)fetchUserWithId:(NSString *)userId completionBlock:(void (^)(User *))completion {
    User *user = [self fetchLocalUserWithId:userId];
    if (user) {
        completion(user);
    } else {
        [[HRPGManager sharedManager] fetchMember:userId onSuccess:^{
            completion([self fetchLocalUserWithId:userId]);
        } onError:nil];
    }
}

+ (User *)fetchLocalUserWithId:(NSString *)userId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                               inManagedObjectContext:[[HRPGManager sharedManager] getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", userId]];
    
    NSError *error;
    NSArray *results = [[[HRPGManager sharedManager] getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (results.count > 0) {
        User *member = results[0];
        return member;
    }
    return nil;
}

- (void)setAvatarSubview:(UIView *)view showsBackground:(BOOL)showsBackground showsMount:(BOOL)showsMount showsPet:(BOOL)showsPet {
    [self setAvatarSubview:view showsBackground:showsBackground showsMount:showsMount showsPet:showsPet isFainted:NO];
}

- (void)setAvatarSubview:(UIView *)view
         showsBackground:(BOOL)showsBackground
              showsMount:(BOOL)showsMount
                showsPet:(BOOL)showsPet
               isFainted:(BOOL)isFainted {
    // clear existing subviews
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIView *avatarView =
        [self getAvatarViewShowsBackground:showsBackground showsMount:showsMount showsPet:showsPet isFainted:isFainted];

    if (!avatarView || !view) {
        return;
    }

    [view addSubview:avatarView];

    // center avatar view constraints
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) { 
        make.center.equalTo(view);
    }];

    // aspect fit view constraints
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(view.mas_width);
        make.height.lessThanOrEqualTo(view.mas_height);
        make.width.equalTo(view.mas_width).priorityHigh();
        make.height.equalTo(view.mas_height).priorityHigh();
    }];
}

- (UIView *)getAvatarViewShowsBackground:(BOOL)showsBackground
                              showsMount:(BOOL)showsMount
                                showsPet:(BOOL)showsPet{
    return [self getAvatarViewShowsBackground:showsBackground showsMount:showsMount showsPet:showsPet isFainted:NO];
}

- (UIView *)getAvatarViewShowsBackground:(BOOL)showsBackground
                              showsMount:(BOOL)showsMount
                                showsPet:(BOOL)showsPet
                               isFainted:(BOOL)isFainted  {
    if (!self.preferences.skin) {
        return nil;
    }

    UIView *avatarView = [[UIView alloc] initWithFrame:CGRectZero];
    CGSize boxSize = (showsBackground || showsMount || showsPet) ? CGSizeMake(140.0, 147.0)
                                                                 : CGSizeMake(90.0, 90.0);

    // keep avatar view size ratio
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(avatarView.mas_width).multipliedBy(boxSize.height / boxSize.width);
    }];

    NSDictionary *viewDictionary = [self getAvatarViewDictionary:showsBackground showsMount:showsMount showsPet:showsPet isFainted:isFainted];

    // avatar view layer order
    NSArray *viewOrder = nil;
  
    if ([self getVisualBuff].length > 0) {
        viewOrder = @[
                      @"background",
                      @"mount-body",
                      @"visual-buff",
                      @"mount-head",
                      @"zzz",
                      @"knockout",
                      @"pet"
                      ];
    } else {
        viewOrder = @[
                      @"background",
                      @"mount-body",
                      @"chair",
                      @"back",
                      @"skin",
                      @"shirt",
                      @"skin",
                      @"shirt",
                      @"armor",
                      @"body",
                      @"head_0",
                      @"hair-base",
                      @"hair-bangs",
                      @"hair-mustache",
                      @"hair-beard",
                      @"eyewear",
                      @"head",
                      @"head-accessory",
                      @"hair-flower",
                      @"shield",
                      @"weapon",
                      @"visual-buff",
                      @"mount-head",
                      @"zzz",
                      @"knockout",
                      @"pet"
                      ];
    }

    // get file dictionary here so it will only be loaded once per avatar view
    NSDictionary *filenameDictionary = [self _getFilenameDictionary];
    NSDictionary *formatDictionary = [self _getFileFormatDictionary];

    // generate avatar view layers
    [viewOrder enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        // check if view layer is enabled
        if (((NSNumber *)viewDictionary[obj]).boolValue) {
            [self _createAvatarSubviewForType:(NSString *)obj
                                    superview:avatarView
                                         size:boxSize
                                     hasMount:((NSNumber *)viewDictionary[@"mount-head"]).boolValue
                       withFilenameDictionary:filenameDictionary
                     withFileFormatDictionary:formatDictionary];
        }
    }];

    return avatarView;
}

- (NSDictionary *)getAvatarViewDictionary:(BOOL)showsBackground
                               showsMount:(BOOL)showsMount
                                 showsPet:(BOOL)showsPet
                                isFainted:(BOOL)isFainted {
    Outfit *outfit = [self.preferences.useCostume boolValue] ? self.costume : self.equipped;
    
    // avatar view layer availability @YES or @NO
    return @{
                                     @"background" : @(showsBackground && self.preferences.background.length),
                                     @"mount-body" : @(showsMount && self.currentMount.length),
                                     @"chair" : @(self.preferences.chair.length && ![self.preferences.chair isEqualToString:@"none"]),
                                     @"back" : @(outfit.back.length && [self _isAvailableGear:outfit.back]),
                                     @"skin" : @YES,
                                     @"shirt" : @YES,
                                     @"armor" : @(outfit.armor.length && [self _isAvailableGear:outfit.armor]),
                                     @"body" : @(outfit.body.length && [self _isAvailableGear:outfit.body]),
                                     @"head_0" : @YES,
                                     @"hair-base" : @(self.preferences.hairBase.integerValue),
                                     @"hair-bangs" : @(self.preferences.hairBangs.integerValue),
                                     @"hair-mustache" : @(self.preferences.hairMustache.integerValue),
                                     @"hair-beard" : @(self.preferences.hairBeard.integerValue),
                                     @"eyewear" : @(outfit.eyewear.length && [self _isAvailableGear:outfit.eyewear]),
                                     @"head" : @(outfit.head.length && [self _isAvailableGear:outfit.head]),
                                     @"head-accessory" :
                                         @(outfit.headAccessory.length && [self _isAvailableGear:outfit.headAccessory]),
                                     @"hair-flower" : @(self.preferences.hairFlower.integerValue),
                                     @"shield" : @(outfit.shield.length && [self _isAvailableGear:outfit.shield]),
                                     @"weapon" : @(outfit.weapon.length && [self _isAvailableGear:outfit.weapon]),
                                     @"visual-buff" : [self getVisualBuff].length ? @YES : @NO,
                                     @"mount-head" : @(showsMount && self.currentMount.length),
                                     @"zzz" : [self.preferences.sleep boolValue] && !isFainted ? @YES : @NO,
                                     @"knockout" : isFainted ? @YES : @NO,
                                     @"pet" : @(showsPet && self.currentPet.length)
                                     };
}

- (UIColor *)classColor {
    if ([self.hclass isEqualToString:@"warrior"]) {
        return [UIColor red100];
    } else if ([self.hclass isEqualToString:@"mage"]) {
        return [UIColor blue100];
    } else if ([self.hclass isEqualToString:@"rogue"]) {
        return [UIColor purple50];
    } else if ([self.hclass isEqualToString:@"healer"]) {
        return [UIColor yellow100];
    } else {
        return [UIColor blackColor];
    }
}

- (UIColor *)contributorColor {
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
    return [UIColor gray10];
}

- (void)setPetCountFromArray:(NSArray *)petArray {
    _petCount = @((int)[petArray count]);
}

- (NSArray *)challengeArray {
    NSMutableArray *challengeArray = [NSMutableArray array];
    for (Challenge *challenge in self.challenges) {
        [challengeArray addObject:challenge.id];
    }
    return challengeArray;
}

- (void)setChallengeArray:(NSArray *)challengeArray {
    NSManagedObjectContext *managedObjectContext =
    [HRPGManager sharedManager].getManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Challenge" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *challenges = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Challenge *challenge in challenges) {
        if ([challengeArray containsObject:challenge.id]) {
            if (![self.challenges containsObject:challenge]) {
                [self addChallengesObject:challenge];
            }
        } else {
            if ([self.challenges containsObject:challenge]) {
                [self removeChallengesObject:challenge];
                challenge.user = nil;
            }
        }
    }
}

- (void)setCustomizationsDictionary:(NSDictionary *)customizationDictionary {
    if (customizationDictionary.count == 0) {
        return;
    }
    NSMutableDictionary *dict = [customizationDictionary mutableCopy];

    NSManagedObjectContext *managedObjectContext =
        [HRPGManager sharedManager].getManagedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *customizations =
        [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

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

    for (NSString *type in @[ @"background", @"shirt", @"skin" ]) {
        for (NSString *key in dict[type]) {
            Customization *customization =
                [NSEntityDescription insertNewObjectForEntityForName:@"Customization"
                                              inManagedObjectContext:managedObjectContext];
            customization.name = key;
            customization.type = type;
            customization.purchased = dict[type][key];
            [managedObjectContext save:&error];
        }
    }

    for (NSString *group in @[ @"color", @"bangs", @"beard", @"mustache" ]) {
        for (NSString *key in dict[@"hair"][group]) {
            Customization *customization =
                [NSEntityDescription insertNewObjectForEntityForName:@"Customization"
                                              inManagedObjectContext:managedObjectContext];
            customization.name = key;
            customization.type = @"hair";
            customization.group = group;
            customization.purchased = dict[@"hair"][group][key];
            [managedObjectContext save:&error];
        }
    }
}

- (NSArray *)equippedArray {
    NSMutableArray *array = [NSMutableArray array];
    Outfit *outfit = [self.preferences.useCostume boolValue] ? self.costume : self.equipped;
    if (outfit.armor) {
        [array addObject:outfit.armor];
    }
    if (outfit.back) {
        [array addObject:outfit.back];
    }
    if (outfit.body) {
        [array addObject:outfit.body];
    }
    if (outfit.eyewear) {
        [array addObject:outfit.eyewear];
    }
    if (outfit.head) {
        [array addObject:outfit.head];
    }
    if (outfit.headAccessory) {
        [array addObject:outfit.headAccessory];
    }
    if (outfit.shield) {
        [array addObject:outfit.shield];
    }
    if (outfit.weapon) {
        [array addObject:outfit.weapon];
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
        if (i != 0 && i % 4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }

    return userAccountHash;
}

- (BOOL)hasSeenTutorialStepWithIdentifier:(NSString *)identifier {
    for (TutorialSteps *tutorialStep in self.flags.iOSTutorialSteps) {
        if ([tutorialStep.identifier isEqualToString:identifier]) {
            return [tutorialStep.wasShown boolValue];
        }
    }
    for (TutorialSteps *tutorialStep in self.flags.commonTutorialSteps) {
        if ([tutorialStep.identifier isEqualToString:identifier]) {
            return [tutorialStep.wasShown boolValue];
        }
    }
    return YES;
}

- (void)willSave {
    if (self.nextLevel.integerValue == 0) {
        self.nextLevel = @(lroundf((([self.level floatValue] * [self.level floatValue] * 0.25) +
                                    10 * [self.level floatValue] + 139.75) /
                                   10) *
                           10);
    }

    if (self.maxMagic.integerValue == 0) {
    }
}

#pragma mark - Private Methods

- (NSDictionary *)_getFilenameDictionary {
    Outfit *outfit = [self.preferences.useCostume boolValue] ? self.costume : self.equipped;
    return @{
        @"background" : [NSString stringWithFormat:@"background_%@", self.preferences.background],
        @"mount-body" : [NSString stringWithFormat:@"Mount_Body_%@", self.currentMount],
        @"chair" : [NSString stringWithFormat:@"chair_%@", self.preferences.chair],
        @"back" : outfit.back ?: [NSNull null],
        @"skin" : ([self.preferences.sleep boolValue])
                      ? [NSString stringWithFormat:@"skin_%@_sleep", self.preferences.skin]
                      : [NSString stringWithFormat:@"skin_%@", self.preferences.skin],
        @"shirt" : [NSString
            stringWithFormat:@"%@_shirt_%@", self.preferences.size, self.preferences.shirt],
        @"armor" : [NSString stringWithFormat:@"%@_%@", self.preferences.size, outfit.armor],
        @"body" : outfit.body ?: [NSNull null],
        @"head_0" : @"head_0",
        @"hair-base" : [NSString stringWithFormat:@"hair_base_%@_%@", self.preferences.hairBase,
                                                  self.preferences.hairColor],
        @"hair-bangs" : [NSString stringWithFormat:@"hair_bangs_%@_%@", self.preferences.hairBangs,
                                                   self.preferences.hairColor],
        @"hair-mustache" :
            [NSString stringWithFormat:@"hair_mustache_%@_%@", self.preferences.hairMustache,
                                       self.preferences.hairColor],
        @"hair-beard" : [NSString stringWithFormat:@"hair_beard_%@_%@", self.preferences.hairBeard,
                                                   self.preferences.hairColor],
        @"eyewear" : outfit.eyewear ?: [NSNull null],
        @"head" : outfit.head ?: [NSNull null],
        @"head-accessory" : outfit.headAccessory ?: [NSNull null],
        @"hair-flower" : [NSString stringWithFormat:@"hair_flower_%@", self.preferences.hairFlower],
        @"shield" : outfit.shield ?: [NSNull null],
        @"weapon" : outfit.weapon ?: [NSNull null],
        @"visual-buff" : [self getVisualBuff],
        @"mount-head" : [NSString stringWithFormat:@"Mount_Head_%@", self.currentMount],
        @"zzz" : @"zzz",
        @"knockout" : @"knockout",
        @"pet" : [NSString stringWithFormat:@"Pet-%@", self.currentPet]
    };
}

- (NSDictionary *)_getFileFormatDictionary {
    return @{
        @"head_special_0" : @"gif",
        @"head_special_1" : @"gif",
        @"shield_special_0" : @"gif",
        @"weapon_special_0" : @"gif",
        @"slim_armor_special_0" : @"gif",
        @"slim_armor_special_1" : @"gif",
        @"broad_armor_special_0" : @"gif",
        @"broad_armor_special_1" : @"gif",
        @"weapon_special_critical" : @"gif",
        @"Pet-Wolf-Cerberus" : @"gif"
    };
}

- (NSURL *)_getImageURL:(nonnull NSString *)type
      withFilenameDictionary:(nonnull NSDictionary *)filenameDictionary
    withFileFormatDictionary:(nonnull NSDictionary *)formatDictionary {
    NSString *rootUrl = @"https://habitica-assets.s3.amazonaws.com/"
                        @"mobileApp/images/";

    NSString *filename = filenameDictionary[type];
    NSString *format = (formatDictionary[filename]) ? formatDictionary[filename] : @"png";

    // NOTE: URL might be incorrect, and should be logged later after request response
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.%@", rootUrl, filename, format]];
}

- (void)_setDefaultConstraintsForType:(nonnull NSString *)type
                            superview:(nonnull UIView *)superview
                              subview:(nonnull UIView *)subview
                                 size:(CGSize)size
                             hasMount:(BOOL)hasMount {
    void (^background)(UIView *, UIView *, CGSize) =
        ^(UIView *superview, UIView *subview, CGSize size) {
            [subview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(superview);
            }];
        };

    void (^mount)(UIView *, UIView *, CGSize) = ^(UIView *superview, UIView *subview, CGSize size) {
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(superview.mas_trailing).multipliedBy(25.0 / size.width);
            make.top.equalTo(superview.mas_bottom).multipliedBy(18.0 / size.height);
        }];
    };
    
    CGFloat topOffset = 0.0;
    if (!hasMount && size.height > 90.0) {
        topOffset = 18.0;
    }

    void (^character)(UIView *, UIView *, CGSize) =
        ^(UIView *superview, UIView *subview, CGSize size) {
            [subview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo((size.width > 90.0) ? superview.mas_trailing
                                                         : superview.mas_leading)
                    .multipliedBy((size.width > 90.0) ? 25.0 / size.width : 1.0);
                make.top.equalTo(superview).offset(topOffset);
            }];
        };

    void (^pet)(UIView *, UIView *, CGSize) = ^(UIView *superview, UIView *subview, CGSize size) {
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.equalTo(superview);
        }];
    };

    void (^weaponSpecial)(UIView *, UIView *, CGSize) =
        ^(UIView *superview, UIView *subview, CGSize size) {
            [subview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(superview.mas_trailing)
                    .multipliedBy((size.width > 90.0) ? 13.0 / size.width : -12 / size.width);
                make.top.equalTo(superview.mas_bottom).multipliedBy(12.0 / size.height);
            }];
        };
    
    void (^weaponSpecial1)(UIView *, UIView *, CGSize) =
    ^(UIView *superview, UIView *subview, CGSize size) {
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(superview.mas_trailing)
            .multipliedBy((size.width > 90.0) ? 13.0 / size.width : -12 / size.width);
            make.top.equalTo(superview).offset(topOffset+3.0);
        }];
    };
    
    void (^headSpecial)(UIView *, UIView *, CGSize) =
    ^(UIView *superview, UIView *subview, CGSize size) {
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo((size.width > 90.0) ? superview.mas_trailing
                                 : superview.mas_leading)
            .multipliedBy((size.width > 90.0) ? 25.0 / size.width : 1.0);
            make.top.equalTo(superview).offset(topOffset+3.0);
        }];
    };

    NSDictionary *constraintsDictionary = @{
        @"background" : background,
        @"mount-body" : mount,
        @"chair" : character,
        @"back" : character,
        @"skin" : character,
        @"shirt" : character,
        @"armor" : character,
        @"body" : character,
        @"head_0" : character,
        @"hair-base" : character,
        @"hair-bangs" : character,
        @"hair-mustache" : character,
        @"hair-beard" : character,
        @"eyewear" : character,
        @"head" : character,
        @"head-accessory" : character,
        @"hair-flower" : character,
        @"shield" : character,
        @"weapon" : character,
        @"mount-head" : mount,
        @"visual-buff" : character,
        @"zzz" : character,
        @"knockout" : character,
        @"pet" : pet,
        @"weapon_special_critical" : weaponSpecial,
        @"weapon_special_1" : weaponSpecial1,
        @"head_special_0" : headSpecial,
        @"head_special_1" : headSpecial
    };

    // [category]:[item]
    // allow item specific constraints to replace category constraints if defined
    // eg. weapon:weapon_special_critical
    NSArray *typeArray = [type componentsSeparatedByString:@":"];

    if (typeArray.count > 1 && constraintsDictionary[typeArray[1]]) {
        ((void (^)(UIView *superview, UIView *subview,
                   CGSize size))constraintsDictionary[typeArray[1]])(superview, subview, size);
    } else if (constraintsDictionary[typeArray[0]]) {
        ((void (^)(UIView *superview, UIView *subview,
                   CGSize size))constraintsDictionary[typeArray[0]])(superview, subview, size);
    }
}

- (void)_setConstraintsForLoadedImage:(nonnull UIImage *)image
                                 type:(nonnull NSString *)type
                            superview:(nonnull UIView *)superview
                              subview:(nonnull UIView *)subview
                                 size:(CGSize)size {
    void (^keepRatio)(UIImage *, UIView *, UIView *, CGSize) =
        ^(UIImage *image, UIView *superview, UIView *subview, CGSize size) {
            [subview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(subview.mas_width)
                    .multipliedBy(image.size.height / image.size.width);
                make.width.equalTo(superview.mas_width).multipliedBy(image.size.width / size.width);
            }];
        };

    NSDictionary *constraintsDictionary = @{
        @"background" : [NSNull null],
        @"mount-body" : keepRatio,
        @"chair" : keepRatio,
        @"back" : keepRatio,
        @"skin" : keepRatio,
        @"shirt" : keepRatio,
        @"armor" : keepRatio,
        @"body" : keepRatio,
        @"head_0" : keepRatio,
        @"hair-base" : keepRatio,
        @"hair-bangs" : keepRatio,
        @"hair-mustache" : keepRatio,
        @"hair-beard" : keepRatio,
        @"eyewear" : keepRatio,
        @"head" : keepRatio,
        @"head-accessory" : keepRatio,
        @"hair-flower" : keepRatio,
        @"shield" : keepRatio,
        @"weapon" : keepRatio,
        @"visual-buff" : keepRatio,
        @"mount-head" : keepRatio,
        @"zzz" : keepRatio,
        @"pet" : keepRatio
    };

    NSArray *typeArray = [type componentsSeparatedByString:@":"];

    if (typeArray.count > 1 && constraintsDictionary[typeArray[1]]) {
        ((void (^)(UIImage *, UIView *, UIView *, CGSize))constraintsDictionary[typeArray[1]])(
            image, superview, subview, size);
    } else if (constraintsDictionary[typeArray[0]] && constraintsDictionary[typeArray[0]] != [NSNull null]) {
        ((void (^)(UIImage *, UIView *, UIView *, CGSize))constraintsDictionary[typeArray[0]])(
            image, superview, subview, size);
    }
}

- (void)_createAvatarSubviewForType:(nonnull NSString *)type
                          superview:(nonnull UIView *)superview
                               size:(CGSize)size
                           hasMount:(BOOL)hasMount
             withFilenameDictionary:(nonnull NSDictionary *)filenameDictionary
           withFileFormatDictionary:(nonnull NSDictionary *)formatDictionary {
    UIImageView *view = [YYAnimatedImageView new];
    [superview addSubview:view];

    NSString *filename = filenameDictionary[type];
    NSString *constraintTypeString =
        (filename.length) ? [NSString stringWithFormat:@"%@:%@", type, filename] : type;

    [view yy_setImageWithURL:[self _getImageURL:type
                                   withFilenameDictionary:filenameDictionary
                                 withFileFormatDictionary:formatDictionary]
        placeholder:nil
        options:YYWebImageOptionShowNetworkActivity
        progress:nil
        transform:^UIImage *_Nullable(UIImage *_Nonnull image, NSURL *_Nonnull url) {
            return [YYImage imageWithData:[image yy_imageDataRepresentation] scale:1.0];
        }
        completion:^(UIImage *_Nullable image, NSURL *_Nonnull url, YYWebImageFromType from,
                     YYWebImageStage stage, NSError *_Nullable error) {
            if (image) {
                [self _setConstraintsForLoadedImage:image
                                               type:constraintTypeString
                                          superview:superview
                                            subview:view
                                               size:size];
            } else {
                NSLog(@"%@: %@", url, error);
            }
        }];

    [self _setDefaultConstraintsForType:constraintTypeString
                              superview:superview
                                subview:view
                                   size:size
                               hasMount:hasMount];
}

- (BOOL)_isAvailableGear:(nonnull NSString *)gearName {
    return [gearName rangeOfString:@"_base_0"].location == NSNotFound;
}

- (NSString *) getVisualBuff {
    if ([self.buff.seafoam boolValue]) {
        return @"seafoam_star";
    }
    if ([self.buff.shinySeed boolValue]) {
        return [@"avatar_floral_" stringByAppendingString:self.hclass];
    }
    if ([self.buff.spookySparkles boolValue]) {
        return @"ghost";
    }
    if ([self.buff.snowball boolValue]) {
        return @"snowman";
    }
    return @"";
}

- (BOOL)didCronRunToday {
    return ![self.needsCron boolValue];
}

- (BOOL)isSubscribed {
    return self.subscriptionPlan.customerId != nil && (self.subscriptionPlan.dateTerminated == nil || [self.subscriptionPlan.dateTerminated compare:[NSDate date]] != NSOrderedDescending);
}

- (BOOL)hasClassSelected {
    return [self.level integerValue] >= 10 && ![self.preferences.disableClass boolValue];
}

- (BOOL)isModerator {
    return [self.contributorLevel intValue] >= 8;
}

@end
