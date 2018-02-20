//
//  ChatMessage+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessage+CoreDataProperties.h"

@implementation ChatMessage (CoreDataProperties)

+ (NSFetchRequest<ChatMessage *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
}

@dynamic attributedText;
@dynamic backerLevel;
@dynamic backerNpc;
@dynamic contributorLevel;
@dynamic contributorText;
@dynamic id;
@dynamic text;
@dynamic timestamp;
@dynamic user;
@dynamic uuid;
@dynamic avatar;
@dynamic group;
@dynamic likes;
@dynamic userObject;

@end
