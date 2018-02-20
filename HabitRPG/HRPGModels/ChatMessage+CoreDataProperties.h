//
//  ChatMessage+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChatMessage (CoreDataProperties)

+ (NSFetchRequest<ChatMessage *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSAttributedString *attributedText;
@property (nullable, nonatomic, copy) NSNumber *backerLevel;
@property (nullable, nonatomic, copy) NSString *backerNpc;
@property (nullable, nonatomic, copy) NSNumber *contributorLevel;
@property (nullable, nonatomic, copy) NSString *contributorText;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, copy) NSString *user;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, retain) ChatMessageAvatar *avatar;
@property (nullable, nonatomic, retain) Group *group;
@property (nullable, nonatomic, retain) NSSet<ChatMessageLike *> *likes;
@property (nullable, nonatomic, retain) User *userObject;

@end

@interface ChatMessage (CoreDataGeneratedAccessors)

- (void)addLikesObject:(ChatMessageLike *)value;
- (void)removeLikesObject:(ChatMessageLike *)value;
- (void)addLikes:(NSSet<ChatMessageLike *> *)values;
- (void)removeLikes:(NSSet<ChatMessageLike *> *)values;

@end

NS_ASSUME_NONNULL_END
