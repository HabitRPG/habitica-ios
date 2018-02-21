//
//  ChatMessageFlag+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessageFlag+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageFlag (CoreDataProperties)

+ (NSFetchRequest<ChatMessageFlag *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *userID;
@property (nullable, nonatomic, retain) NSSet<ChatMessage *> *messages;

@end

@interface ChatMessageFlag (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSSet<ChatMessage *> *)values;
- (void)removeMessages:(NSSet<ChatMessage *> *)values;

@end

NS_ASSUME_NONNULL_END
