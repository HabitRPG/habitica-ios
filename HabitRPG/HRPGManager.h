//
//  HRPGManager.h
//  HabitRPG
//
//  Created by Phillip Thelen on 09/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData/RKManagedObjectStore.h>
#import "ChatMessage.h"
#import "Food.h"
#import "Group.h"
#import "MetaReward.h"
#import "Pet.h"
#import "Task.h"
#import "User.h"
#import "User.h"
#import "item.h"

@interface HRPGManager : NSObject

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) User *user;

- (void)loadObjectManager:(RKManagedObjectStore *)existingManagedObjectStore;

- (void)fetchContent:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchTasks:(void (^)())successBlock onError:(void (^)())errorBlock;
- (void)fetchCompletedTasks:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchUser:(void (^)())successBlock onError:(void (^)())errorBlock;
- (void)fetchUser:(BOOL)includeTasks
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock;

- (void)updateUser:(NSDictionary *)newValues
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock;

- (void)batchUpdateUser:(NSArray *)actions
              onSuccess:(void (^)())successBlock
                onError:(void (^)())errorBlock;

- (void)changeClass:(NSString *)newClass
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)disableClasses:(void (^)())successBlock
               onError:(void (^)())errorBlock;

- (void)fetchGroup:(NSString *)groupID
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock;

- (void)fetchGroups:(NSString *)groupType
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)fetchMember:(NSString *)memberId
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)upDownTask:(Task *)task
         direction:(NSString *)withDirection
         onSuccess:(void (^)(NSArray *valuesArray))successBlock
           onError:(void (^)())errorBlock;

- (void)scoreChecklistItem:(Task *)task
             checklistItem:(ChecklistItem *)item
                 onSuccess:(void (^)())successBlock
                   onError:(void (^)())errorBlock;

- (void)getReward:(NSString *)rewardID
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock;

- (void)createTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)updateTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)deleteTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)createReward:(Reward *)reward
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock;

- (void)updateReward:(Reward *)reward
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock;

- (void)deleteReward:(Reward *)reward
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock;

- (void)fetchBuyableRewards:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)clearCompletedTasks:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)buyObject:(MetaReward *)reward
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock;

- (void)unlockPath:(NSString *)path
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock;

- (void)sellItem:(Item *)item onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)equipObject:(NSString *)key
           withType:(NSString *)type
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)hatchEgg:(NSString *)egg
      withPotion:(NSString *)hPotion
       onSuccess:(void (^)())successBlock
         onError:(void (^)())errorBlock;

- (void)castSpell:(NSString *)spell
    withTargetType:(NSString *)targetType
          onTarget:(NSString *)target
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock;

- (void)acceptQuest:(NSString *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)rejectQuest:(NSString *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)abortQuest:(NSString *)group
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock;

- (void)cancelQuest:(NSString *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)forceStartQuest:(NSString *)group
              onSuccess:(void (^)())successBlock
                onError:(void (^)())errorBlock;

- (void)inviteToQuest:(NSString *)group
            withQuest:(Quest *)quest
            onSuccess:(void (^)())successBlock
              onError:(void (^)())errorBlock;

- (void)createGroup:(Group *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)updateGroup:(Group *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)fetchGroupMembers:(NSString *)groupID
                   lastID:(NSString *)lastID
         withPublicFields:(BOOL)withPublicFields
                 fetchAll:(BOOL)fetchAll
                onSuccess:(void (^)())successBlock
                  onError:(void (^)())errorBlock;

- (void)inviteMembers:(NSArray *)members
    withInvitationType:(NSString *)invitationType
         toGroupWithID:(NSString *)group
             onSuccess:(void (^)())successBlock
               onError:(void (^)())errorBlock;

- (void)joinGroup:(NSString *)group
         withType:(NSString *)type
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock;

- (void)leaveGroup:(Group *)group
          withType:(NSString *)type
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock;

- (void)chatSeen:(NSString *)group;

- (void)loginUser:(NSString *)username
     withPassword:(NSString *)password
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock;
- (void)loginUserSocial:(NSString *)userID
        withAccessToken:(NSString *)accessToken
              onSuccess:(void (^)())successBlock
                onError:(void (^)())errorBlock;
- (void)registerUser:(NSString *)username
        withPassword:(NSString *)password
           withEmail:(NSString *)email
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock;
- (void)clearLoginCredentials;

- (void)sleepInn:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)reviveUser:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)chatMessage:(NSString *)message
          withGroup:(NSString *)groupID
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)deleteMessage:(ChatMessage *)message
            withGroup:(NSString *)groupID
            onSuccess:(void (^)())successBlock
              onError:(void (^)())errorBlock;

- (void)likeMessage:(ChatMessage *)message
          withGroup:(NSString *)groupID
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)flagMessage:(ChatMessage *)message
          withGroup:(NSString *)groupID
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock;

- (void)feedPet:(Pet *)pet
       withFood:(Food *)food
      onSuccess:(void (^)())successBlock
        onError:(void (^)())errorBlock;

- (void)purchaseGems:(NSDictionary *)receipt
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock;

- (void)purchaseItem:(NSString *)itemName
            fromType:(NSString *)itemType
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock;

- (NSManagedObjectContext *)getManagedObjectContext;

- (void)displayNetworkError;

- (void)setCredentials;

- (User *)getUser;

- (void)getImage:(NSString *)imageName
      withFormat:(NSString *)format
       onSuccess:(void (^)(UIImage *image))successBlock
         onError:(void (^)())ErrorBlock;

- (void)setImage:(NSString *)imageName
      withFormat:(NSString *)format
          onView:(UIImageView *)imageView;

- (UIImage *)getCachedImage:(NSString *)imageName;

- (void)setCachedImage:(UIImage *)image
              withName:(NSString *)imageName
             onSuccess:(void (^)())successBlock;

- (void)resetSavedDatabase:(BOOL)withUserData onComplete:(void (^)())completitionBlock;

- (void)displayTaskSuccessNotification:(NSNumber *)healthDiff
                    withExperienceDiff:(NSNumber *)expDiff
                          withGoldDiff:(NSNumber *)goldDiff
                         withMagicDiff:(NSNumber *)magicDiff;

@end
