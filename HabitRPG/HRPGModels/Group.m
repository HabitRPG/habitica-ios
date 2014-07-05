//
//  Group.m
//  HabitRPG
//
//  Created by Phillip Thelen on 16/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Group.h"
#import "ChatMessage.h"
@implementation Group

@dynamic hdescription;
@dynamic id;
@dynamic name;
@dynamic privacy;
@dynamic questActive;
@dynamic questHP;
@dynamic questRage;
@dynamic questKey;
@dynamic unreadMessages;
@dynamic type;
@dynamic chatmessages;
@dynamic leader;
@dynamic member;
@dynamic collectStatus;

-(void)addChatmessagesObject:(ChatMessage *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.chatmessages];
    value.group = self;
    [tempSet addObject:value];
    self.chatmessages = tempSet;
}


-(void)addChatmessagesObjectAtFirstPosition:(ChatMessage *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.chatmessages];
    value.group = self;
    [tempSet insertObject:value atIndex:0];
    self.chatmessages = tempSet;
}

- (void)removeChatMessagesObject:(ChatMessage *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.chatmessages];
    [tempSet removeObject:value];
    self.chatmessages = tempSet;
}

@end
