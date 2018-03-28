//
//  ChatMessageLike+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessageLike+CoreDataProperties.h"

@implementation ChatMessageLike (CoreDataProperties)

+ (NSFetchRequest<ChatMessageLike *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChatMessageFlag"];
}

@dynamic userID;
@dynamic wasLiked;
@dynamic messages;

@end
