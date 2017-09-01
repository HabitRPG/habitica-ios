//
//  Group.m
//  HabitRPG
//
//  Created by Phillip Thelen on 16/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
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
@dynamic questLeader;
@dynamic questRage;
@dynamic questKey;
@dynamic worldDmgTavern;
@dynamic worldDmgStable;
@dynamic worldDmgMarket;
@dynamic unreadMessages;
@dynamic type;
@dynamic chatmessages;
@dynamic leader;
@dynamic member;
@dynamic questParticipants;
@dynamic collectStatus;
@dynamic isMember;
@dynamic memberCount;
@dynamic balance;

- (void)addChatmessagesObject:(ChatMessage *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.chatmessages];
    value.group = self;
    [tempSet addObject:value];
    self.chatmessages = tempSet;
}

- (void)addChatmessagesObjectAtFirstPosition:(ChatMessage *)value {
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

- (void)setType:(NSString *)type {
    if (type != nil) {
        [self willChangeValueForKey:@"type"];
        [self setPrimitiveValue:type forKey:@"type"];
        [self didChangeValueForKey:@"type"];
    }
}

@end
