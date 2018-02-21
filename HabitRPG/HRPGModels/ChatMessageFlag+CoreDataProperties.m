//
//  ChatMessageFlag+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessageFlag+CoreDataProperties.h"

@implementation ChatMessageFlag (CoreDataProperties)

+ (NSFetchRequest<ChatMessageFlag *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChatMessageFlag"];
}

@dynamic userID;
@dynamic messages;

@end
