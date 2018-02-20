//
//  ChatMessageAvatar+CoreDataClass.h
//  Habitica
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessage, Outfit, Preferences;

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageAvatar : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "ChatMessageAvatar+CoreDataProperties.h"
