//
//  User.h
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Flags.h"
#import "Outfit.h"
#import "Preferences.h"
#import "PushDevice.h"
#import "Buff+CoreDataClass.h"
#import "SpecialItems+CoreDataClass.h"
#import "SubscriptionPlan+CoreDataClass.h"
#import "Challenge+CoreDataClass.h"

@class Egg, Gear, Group, Quest, Reward, Tag, Task, Customization, ImprovementCategory, UIView, UIColor, UIImage, UIImageView;

@interface User : NSManagedObject

@property(nonatomic, retain) NSNumber *balance;
@property(nonatomic, retain) NSString *blurb;
@property(nonatomic, retain) NSNumber *strength;
@property(nonatomic, retain) NSNumber *intelligence;
@property(nonatomic, retain) NSNumber *constitution;
@property(nonatomic, retain) NSNumber *perception;
@property(nonatomic, retain) NSNumber *contributorLevel;
@property(nonatomic, retain) NSString *contributorText;
@property(nonatomic, retain) NSString *currentMount;
@property(nonatomic, retain) NSString *currentPet;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSNumber *experience;
@property(nonatomic, retain) NSNumber *gold;
@property(nonatomic, retain, getter=getCleanedClassName) NSString *hclass;
@property(nonatomic, readonly, getter=getDirtyClassName) NSString *dirtyClass;
@property(nonatomic, retain) NSNumber *health;
@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *invitedParty;
@property(nonatomic, retain) NSString *invitedPartyName;
@property(nonatomic, retain) NSNumber *level;
@property(nonatomic, retain) NSNumber *magic;
@property(nonatomic, retain) NSNumber *maxHealth;
@property(nonatomic, retain) NSNumber *maxMagic;
@property(nonatomic, retain) NSDate *memberSince;
@property(nonatomic, retain) NSNumber *nextLevel;
@property(nonatomic, retain) NSNumber *participateInQuest;
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
@property(nonatomic, retain) NSString *partyOrder;
@property(nonatomic, retain) NSNumber *partyPosition;
@property(nonatomic, retain) NSNumber *petCount;
@property(nonatomic, retain) NSString *partyID;
@property(nonatomic, retain) NSSet *pushDevices;
@property(nonatomic, retain) NSNumber *inboxOptOut;
@property(nonatomic, retain) NSNumber *inboxNewMessages;
@property(nonatomic, retain) NSString *facebookID;
@property(nonatomic, retain) NSString *googleID;
@property(nonatomic, retain) SubscriptionPlan *subscriptionPlan;

@property(nonatomic, retain) Preferences *preferences;
@property(nonatomic, retain) Outfit *costume;
@property(nonatomic, retain) Outfit *equipped;
@property(nonatomic, retain) Flags *flags;
@property(nonatomic, retain) Buff *buff;
@property(nonatomic, retain) SpecialItems *specialItems;
@property(nonatomic, retain) NSSet *challenges;

@property(nonatomic, retain, setter=setPetCountFromArray:) NSDictionary *petCountArray;
@property(nonatomic, retain, setter=setCustomizationsDictionary:)
    NSDictionary *customizationsDictionary;
@property(nonatomic) NSArray *challengeArray;

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

- (void)addChallengesObject:(Challenge *)value;

- (void)removeChallengesObject:(Challenge *)value;

- (void)addChallenges:(NSSet *)values;

- (void)removeChallenges:(NSSet *)values;

- (void)addTasksObject:(Task *)value;

- (void)removeTasksObject:(Task *)value;

- (void)addTasks:(NSSet *)values;

- (void)removeTasks:(NSSet *)values;

- (void)addCustomizationsObject:(Customization *)value;

- (void)removeCustomizationsObject:(Customization *)value;

- (void)addCustomizations:(NSSet *)values;

- (void)removeCustomizations:(NSSet *)values;

- (void)setAvatarSubview:(UIView *)view
         showsBackground:(BOOL)showsBackground
              showsMount:(BOOL)showsMount
                showsPet:(BOOL)showsPet;
- (UIView *)getAvatarViewShowsBackground:(BOOL)showsBackground
                              showsMount:(BOOL)showsMount
                                showsPet:(BOOL)showsPet;

- (void)setAvatarSubview:(UIView *)view
         showsBackground:(BOOL)showsBackground
              showsMount:(BOOL)showsMount
                showsPet:(BOOL)showsPet
               isFainted:(BOOL)isFainted;
- (UIView *)getAvatarViewShowsBackground:(BOOL)showsBackground
                              showsMount:(BOOL)showsMount
                                showsPet:(BOOL)showsPet
                               isFainted:(BOOL)isFainted;

- (UIColor *)classColor;

- (UIColor *)contributorColor;

- (NSArray *)equippedArray;

- (NSString *)hashedValueForAccountName;

- (BOOL)hasSeenTutorialStepWithIdentifier:(NSString *)identifier;

@end
