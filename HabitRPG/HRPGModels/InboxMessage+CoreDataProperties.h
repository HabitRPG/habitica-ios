//
//  InboxMessage+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "InboxMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface InboxMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSNumber *sent;
@property (nullable, nonatomic, retain) NSNumber *sort;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSString *userID;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *backerLevel;
@property (nullable, nonatomic, retain) NSString *backerNpc;
@property (nullable, nonatomic, retain) NSNumber *contributorLevel;
@property (nullable, nonatomic, retain) NSString *contributorText;
@property (nullable, nonatomic, retain) NSNumber *sending;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) NSAttributedString *attributedText;

@end

NS_ASSUME_NONNULL_END
