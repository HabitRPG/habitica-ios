//
//  PushNotifications+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 24/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PushNotifications.h"

NS_ASSUME_NONNULL_BEGIN

@interface PushNotifications (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *giftedGems;
@property (nullable, nonatomic, retain) NSNumber *giftedSubscription;
@property (nullable, nonatomic, retain) NSNumber *invitedGuild;
@property (nullable, nonatomic, retain) NSNumber *invitedParty;
@property (nullable, nonatomic, retain) NSNumber *invitedQuest;
@property (nullable, nonatomic, retain) NSNumber *newPM;
@property (nullable, nonatomic, retain) NSNumber *questStarted;
@property (nullable, nonatomic, retain) NSNumber *wonChallenge;
@property (nullable, nonatomic, retain) NSString *userID;
@property (nullable, nonatomic, retain) NSNumber *unsubscribeFromAll;
@property (nullable, nonatomic, retain) Preferences *preferences;

@end

NS_ASSUME_NONNULL_END
