//
//  ChatMessageAvatar+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessageAvatar+CoreDataProperties.h"

@implementation ChatMessageAvatar (CoreDataProperties)

+ (NSFetchRequest<ChatMessageAvatar *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChatMessageAvatar"];
}

@dynamic background;
@dynamic chair;
@dynamic currentMount;
@dynamic currentPet;
@dynamic hairBangs;
@dynamic hairBase;
@dynamic hairBeard;
@dynamic hairColor;
@dynamic hairFlower;
@dynamic hairMustache;
@dynamic shirt;
@dynamic size;
@dynamic skin;
@dynamic sleep;
@dynamic useCostume;
@dynamic costume;
@dynamic equipped;
@dynamic message;

@end
