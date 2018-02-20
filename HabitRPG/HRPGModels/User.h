//
//  User.h
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
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

@property(nonnull, nonatomic, retain) NSString *loginname;
@property(nonnull, nonatomic, retain) NSString *photoUrl;
@property(nonnull, nonatomic, retain) NSNumber *balance;
@property(nonnull, nonatomic, retain) NSString *blurb;
@property(nullable, nonatomic, retain) NSNumber *strength;
@property(nullable, nonatomic, retain) NSNumber *intelligence;
@property(nullable, nonatomic, retain) NSNumber *constitution;
@property(nullable, nonatomic, retain) NSNumber *perception;
@property(nonnull, nonatomic, retain) NSNumber *contributorLevel;
@property(nonnull, nonatomic, retain) NSString *contributorText;
@property(nonnull, nonatomic, retain) NSString *currentMount;
@property(nonnull, nonatomic, retain) NSString *currentPet;
@property(nonnull, nonatomic, retain) NSString *email;
@property(nonnull, nonatomic, retain) NSNumber *experience;
@property(nonnull, nonatomic, retain) NSNumber *gold;
@property(nullable, nonatomic, retain, getter=getCleanedClassName) NSString *hclass;
@property(nonnull, nonatomic, readonly, getter=getDirtyClassName) NSString *dirtyClass;
@property(nonnull, nonatomic, retain) NSNumber *health;
@property(nonnull, nonatomic, retain) NSString *id;
@property(nonnull, nonatomic, retain) NSString *invitedParty;
@property(nonnull, nonatomic, retain) NSString *invitedPartyName;
@property(nonnull, nonatomic, retain) NSNumber *level;
@property(nonnull, nonatomic, retain) NSNumber *magic;
@property(nonnull, nonatomic, retain) NSNumber *maxHealth;
@property(nonnull, nonatomic, retain) NSNumber *maxMagic;
@property(nonnull, nonatomic, retain) NSDate *memberSince;
@property(nonnull, nonatomic, retain) NSNumber *nextLevel;
@property(nonnull, nonatomic, retain) NSNumber *participateInQuest;
@property(nonnull, nonatomic, retain) NSString *username;
@property(nonnull, nonatomic, retain) NSSet *groups;
@property(nonnull, nonatomic, retain) NSSet *ownedEggs;
@property(nonnull, nonatomic, retain) NSSet *ownedFood;
@property(nonnull, nonatomic, retain) NSSet *ownedGear;
@property(nonnull, nonatomic, retain) NSSet *ownedHatchingPotions;
@property(nonnull, nonatomic, retain) NSSet *ownedQuests;
@property(nonnull, nonatomic, retain) Group *party;
@property(nonnull, nonatomic, retain) NSSet *rewards;
@property(nonnull, nonatomic, retain) NSSet *tags;
@property(nonnull, nonatomic, retain) NSSet *tasks;
@property(nonnull, nonatomic, retain) NSDate *lastLogin;
@property(nonnull, nonatomic, retain) NSDate *lastAvatarFull;
@property(nonnull, nonatomic, retain) NSDate *lastAvatarNoPet;
@property(nonnull, nonatomic, retain) NSDate *lastAvatarHead;
@property(nonnull, nonatomic, retain) NSString *partyOrder;
@property(nonnull, nonatomic, retain) NSNumber *partyPosition;
@property(nonnull, nonatomic, retain) NSNumber *petCount;
@property(nonnull, nonatomic, retain) NSString *partyID;
@property(nonnull, nonatomic, retain) NSSet *pushDevices;
@property(nonnull, nonatomic, retain) NSNumber *inboxOptOut;
@property(nonnull, nonatomic, retain) NSNumber *inboxNewMessages;
@property(nonnull, nonatomic, retain) NSString *facebookID;
@property(nonnull, nonatomic, retain) NSString *googleID;
@property(nonnull, nonatomic, retain) SubscriptionPlan *subscriptionPlan;
@property(nonnull, nonatomic, retain) NSDate *lastCron;
@property(nonnull, nonatomic, retain) NSNumber *needsCron;
@property(nonnull, nonatomic, retain) NSNumber *loginIncentives;
@property(nonnull, nonatomic, retain) NSNumber *pointsToAllocate;
@property(nonnull, nonatomic, retain) NSNumber *pendingDamage;

@property(nullable, nonatomic, retain) Preferences *preferences;
@property(nullable, nonatomic, retain) Outfit *costume;
@property(nullable, nonatomic, retain) Outfit *equipped;
@property(nullable, nonatomic, retain) Flags *flags;
@property(nullable, nonatomic, retain) Buff *buff;
@property(nullable, nonatomic, retain) SpecialItems *specialItems;
@property(nullable, nonatomic, retain) NSSet *challenges;

@property(nullable, nonatomic, retain, setter=setPetCountFromArray:) NSDictionary *petCountArray;
@property(nullable, nonatomic, retain, setter=setCustomizationsDictionary:)
    NSDictionary *customizationsDictionary;
@property(nullable, nonatomic) NSArray *challengeArray;

@end

@interface User (ConvenienceMethods)
+ (void)fetchUserWithId:(NSString *)userId completionBlock:(void (^)(User *))completion;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *_Nonnull)value;

- (void)removeGroupsObject:(Group *_Nonnull)value;

- (void)addGroups:(NSSet *_Nonnull)values;

- (void)removeGroups:(NSSet *_Nonnull)values;

- (void)addOwnedEggsObject:(Egg *_Nonnull)value;

- (void)removeOwnedEggsObject:(Egg *_Nonnull)value;

- (void)addOwnedEggs:(NSSet *_Nonnull)values;

- (void)removeOwnedEggs:(NSSet *_Nonnull)values;

- (void)addOwnedFoodObject:(NSManagedObject *_Nonnull)value;

- (void)removeOwnedFoodObject:(NSManagedObject *_Nonnull)value;

- (void)addOwnedFood:(NSSet *_Nonnull)values;

- (void)removeOwnedFood:(NSSet *_Nonnull)values;

- (void)addOwnedGearObject:(Gear *_Nonnull)value;

- (void)removeOwnedGearObject:(Gear *_Nonnull)value;

- (void)addOwnedGear:(NSSet *_Nonnull)values;

- (void)removeOwnedGear:(NSSet *_Nonnull)values;

- (void)addOwnedHatchingPotionsObject:(NSManagedObject *_Nonnull)value;

- (void)removeOwnedHatchingPotionsObject:(NSManagedObject *_Nonnull)value;

- (void)addOwnedHatchingPotions:(NSSet *_Nonnull)values;

- (void)removeOwnedHatchingPotions:(NSSet *_Nonnull)values;

- (void)addOwnedQuestsObject:(Quest *_Nonnull)value;

- (void)removeOwnedQuestsObject:(Quest *_Nonnull)value;

- (void)addOwnedQuests:(NSSet *_Nonnull)values;

- (void)removeOwnedQuests:(NSSet *_Nonnull)values;

- (void)addTagsObject:(Tag *_Nonnull)value;

- (void)removeTagsObject:(Tag *_Nonnull)value;

- (void)addTags:(NSSet *_Nonnull)values;

- (void)removeTags:(NSSet *_Nonnull)values;

- (void)addChallengesObject:(Challenge *_Nonnull)value;

- (void)removeChallengesObject:(Challenge *_Nonnull)value;

- (void)addChallenges:(NSSet *_Nonnull)values;

- (void)removeChallenges:(NSSet *_Nonnull)values;

- (void)addTasksObject:(Task *_Nonnull)value;

- (void)removeTasksObject:(Task *_Nonnull)value;

- (void)addTasks:(NSSet *_Nonnull)values;

- (void)removeTasks:(NSSet *_Nonnull)values;

- (void)addCustomizationsObject:(Customization *_Nonnull)value;

- (void)removeCustomizationsObject:(Customization *_Nonnull)value;

- (void)addCustomizations:(NSSet *_Nonnull)values;

- (void)removeCustomizations:(NSSet *_Nonnull)values;

- (UIColor *_Nonnull)classColor;

- (UIColor *_Nonnull)contributorColor;

- (NSArray *_Nonnull)equippedArray;

- (NSString *_Nonnull)hashedValueForAccountName;

- (BOOL)hasSeenTutorialStepWithIdentifier:(NSString *_Nonnull)identifier;

- (BOOL)didCronRunToday;

- (BOOL)isSubscribed;

- (BOOL)hasClassSelected;

- (BOOL)isModerator;

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

@end
