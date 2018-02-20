//
//  ChatMessage+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessageAvatar, ChatMessageLike, Group, NSObject, User;

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessage : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "ChatMessage+CoreDataProperties.h"
