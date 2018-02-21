//
//  ChatMessageLike+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessage;

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageLike : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "ChatMessageLike+CoreDataProperties.h"
