//
//  User.h
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Egg, Gear, Group, Quest, Reward, Tag, Task, Customization;

@interface User : NSManagedObject

@property(nonatomic, retain) NSNumber *armoireEnabled;
@property(nonatomic, retain) NSNumber *armoireEmpty;
@property(nonatomic, retain) NSNumber *acceptedCommunityGuidelines;
@property(nonatomic, retain) NSString *background;
@property(nonatomic, retain) NSNumber *balance;
@property(nonatomic, retain) NSString *blurb;
@property(nonatomic, retain) NSNumber *contributorLevel;
@property(nonatomic, retain) NSString *contributorText;
@property(nonatomic, retain) NSString *costumeArmor;
@property(nonatomic, retain) NSString *costumeBack;
@property(nonatomic, retain) NSString *costumeBody;
@property(nonatomic, retain) NSString *costumeEyewear;
@property(nonatomic, retain) NSString *costumeHead;
@property(nonatomic, retain) NSString *costumeHeadAccessory;
@property(nonatomic, retain) NSString *costumeShield;
@property(nonatomic, retain) NSString *costumeWeapon;
@property(nonatomic, retain) NSString *currentMount;
@property(nonatomic, retain) NSString *currentPet;
@property(nonatomic, retain) NSNumber *dayStart;
@property(nonatomic, retain) NSNumber *disableClass;
@property(nonatomic, retain) NSNumber *dropsEnabled;
@property(nonatomic, retain) NSString *equippedArmor;
@property(nonatomic, retain) NSString *equippedBack;
@property(nonatomic, retain) NSString *equippedBody;
@property(nonatomic, retain) NSString *equippedEyewear;
@property(nonatomic, retain) NSString *equippedHead;
@property(nonatomic, retain) NSString *equippedHeadAccessory;
@property(nonatomic, retain) NSString *equippedShield;
@property(nonatomic, retain) NSString *equippedWeapon;
@property(nonatomic, retain) NSNumber *experience;
@property(nonatomic, retain) NSNumber *gold;
@property(nonatomic, retain) NSString *hairBangs;
@property(nonatomic, retain) NSString *hairBase;
@property(nonatomic, retain) NSString *hairBeard;
@property(nonatomic, retain) NSString *hairColor;
@property(nonatomic, retain) NSString *hairMustache;
@property(nonatomic, retain) NSString *hairFlower;
@property(nonatomic, retain, getter = getCleanedClassName) NSString *hclass;
@property(nonatomic, readonly, getter = getDirtyClassName) NSString *dirtyClass;
@property(nonatomic, retain) NSNumber *health;
@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *invitedParty;
@property(nonatomic, retain) NSString *invitedPartyName;
@property(nonatomic, retain) NSNumber *itemsEnabled;
@property(nonatomic, retain) NSNumber *level;
@property(nonatomic, retain) NSNumber *magic;
@property(nonatomic, retain) NSNumber *maxHealth;
@property(nonatomic, retain) NSNumber *maxMagic;
@property(nonatomic, retain) NSDate *memberSince;
@property(nonatomic, retain) NSNumber *nextLevel;
@property(nonatomic, retain) NSNumber *habitNewStuff;
@property(nonatomic, retain) NSNumber *participateInQuest;
@property(nonatomic, retain) NSString *shirt;
@property(nonatomic, retain) NSString *size;
@property(nonatomic, retain) NSString *skin;
@property(nonatomic) Boolean sleep;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSSet *groups;
@property(nonatomic, retain) NSSet *ownedEggs;
@property(nonatomic, retain) NSSet *ownedFood;
@property(nonatomic, retain) NSSet *ownedGear;
@property(nonatomic, retain) NSSet *ownedHatchingPotions;
@property(nonatomic, retain) NSSet *ownedQuests;
@property(nonatomic, retain) Group *party;
@property(nonatomic, retain) NSSet *rewards;
@property(nonatomic, retain) NSSet *tags;
@property(nonatomic, retain) NSSet *tasks;
@property(nonatomic, retain) NSDate *lastLogin;
@property(nonatomic, retain) NSDate *lastAvatarFull;
@property(nonatomic, retain) NSDate *lastAvatarNoPet;
@property(nonatomic, retain) NSDate *lastAvatarHead;
@property(nonatomic, retain) NSNumber *selectedClass;
@property(nonatomic, retain) NSNumber *useCostume;
@property(nonatomic, retain) NSString *partyOrder;
@property(nonatomic, retain) NSNumber *partyPosition;
@property(nonatomic, retain) NSNumber *petCount;

@property(nonatomic, retain) NSNumber *lastSetupStep;

@property(nonatomic, retain, setter = setPetCountFromArray:) NSDictionary *petCountArray;
@property(nonatomic, retain, setter = setCustomizationsDictionary:) NSDictionary *customizationsDictionary;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;

- (void)removeGroupsObject:(Group *)value;

- (void)addGroups:(NSSet *)values;

- (void)removeGroups:(NSSet *)values;

- (void)addOwnedEggsObject:(Egg *)value;

- (void)removeOwnedEggsObject:(Egg *)value;

- (void)addOwnedEggs:(NSSet *)values;

- (void)removeOwnedEggs:(NSSet *)values;

- (void)addOwnedFoodObject:(NSManagedObject *)value;

- (void)removeOwnedFoodObject:(NSManagedObject *)value;

- (void)addOwnedFood:(NSSet *)values;

- (void)removeOwnedFood:(NSSet *)values;

- (void)addOwnedGearObject:(Gear *)value;

- (void)removeOwnedGearObject:(Gear *)value;

- (void)addOwnedGear:(NSSet *)values;

- (void)removeOwnedGear:(NSSet *)values;

- (void)addOwnedHatchingPotionsObject:(NSManagedObject *)value;

- (void)removeOwnedHatchingPotionsObject:(NSManagedObject *)value;

- (void)addOwnedHatchingPotions:(NSSet *)values;

- (void)removeOwnedHatchingPotions:(NSSet *)values;

- (void)addOwnedQuestsObject:(Quest *)value;

- (void)removeOwnedQuestsObject:(Quest *)value;

- (void)addOwnedQuests:(NSSet *)values;

- (void)removeOwnedQuests:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;

- (void)removeTagsObject:(Tag *)value;

- (void)addTags:(NSSet *)values;

- (void)removeTags:(NSSet *)values;

- (void)addTasksObject:(Task *)value;

- (void)removeTasksObject:(Task *)value;

- (void)addTasks:(NSSet *)values;

- (void)removeTasks:(NSSet *)values;

- (void)addCustomizationsObject:(Customization *)value;

- (void)removeCustomizationsObject:(Customization *)value;

- (void)addCustomizations:(NSSet *)values;

- (void)removeCustomizations:(NSSet *)values;

- (void)setAvatarOnImageView:(UIImageView *)imageView useForce:(BOOL)force;

- (void)setAvatarOnImageView:(UIImageView *)imageView withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead useForce:(BOOL)force;
- (void)setAvatarOnImageView:(UIImageView *)imageView withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead withBackground:(BOOL)withBackground useForce:(BOOL)force;
- (void)getAvatarImage:(void (^)(UIImage *))successBlock withPetMount:(BOOL)withPetMount onlyHead:(BOOL)onlyHead withBackground:(BOOL)withBackground useForce:(BOOL)force;
- (UIColor*)classColor;

- (UIColor*)contributorColor;

- (NSArray*)equippedArray;

- (NSString *)hashedValueForAccountName;

@end
