//
//  HRPGManager.h
//  HabitRPG
//
//  Created by Phillip Thelen on 09/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
#import "User.h"
#import "MetaReward.h"
#import "ChatMessage.h"
#import "item.h"

@interface HRPGManager : NSObject

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)loadObjectManager;

- (void)fetchContent:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchTasks:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchUser:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)updateUser:(NSDictionary*)newValues onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchGroup:(NSString *)groupID onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchGroups:(NSString *)groupType onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)fetchMember:(NSString *)memberId onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)upDownTask:(Task *)task direction:(NSString *)withDirection onSuccess:(void (^)(NSArray *valuesArray))successBlock onError:(void (^)())errorBlock;

- (void)getReward:(NSString *)rewardID onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)createTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)updateTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)deleteTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)clearCompletedTasks:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)buyObject:(MetaReward *)reward onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)sellItem:(Item *)item onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)equipObject:(NSString *)key withType:(NSString*)type onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)hatchEgg:(NSString *)egg withPotion:(NSString*)hPotion onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)castSpell:(NSString *)spell withTargetType:(NSString *)targetType onTarget:(NSString *)target onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)acceptQuest:(NSString *)group withQuest:(Quest *)quest useForce:(Boolean)force onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)rejectQuest:(NSString *)group onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)abortQuest:(NSString *)group onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)chatSeen:(NSString *)group;

- (void)loginUser:(NSString *)username withPassword:(NSString *)password onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;
- (void)registerUser:(NSString *)username withPassword:(NSString *)password withEmail:(NSString *)email onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)sleepInn:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)reviveUser:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)chatMessage:(NSString *)message withGroup:(NSString*)groupID onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)deleteMessage:(ChatMessage *)message withGroup:(NSString*)groupID onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (void)feedPet:(NSString *)pet withFood:(NSString*)food onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;

- (NSManagedObjectContext *)getManagedObjectContext;

- (void)displayNetworkError;

- (void)setCredentials;

- (User *)getUser;

- (void)getImage:(NSString *)imageName withFormat:(NSString*)format onSuccess:(void (^)(UIImage *image))successBlock onError:(void (^)())ErrorBlock;

- (UIImage *)getCachedImage:(NSString *)imageName;

- (void)setCachedImage:(UIImage *)image withName:(NSString *)imageName onSuccess:(void (^)())successBlock;

- (void)resetSavedDatabase:(BOOL)withUserData onComplete:(void (^)())completitionBlock;
@end
