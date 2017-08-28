//
//  QuestReward+CoreDataClass.m
//  Habitica
//
//  Created by Phillip on 28.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "QuestReward+CoreDataClass.h"
#import "Quest+CoreDataClass.h"

@implementation QuestReward


- (NSString *)getImageName {
    if ([@"quests" isEqualToString:[self type]]) {
        return [@"inventory_quest_scroll_" stringByAppendingString:[self key]];
    } else if ([@"eggs" isEqualToString:[self type]]) {
        return [@"Pet_Egg_" stringByAppendingString:[self key]];
    } else if ([@"food" isEqualToString:[self type]]) {
        return [@"Pet_Food_" stringByAppendingString:[self key]];
    } else if ([@"hatchingPotions" isEqualToString:[self type]]) {
        return [@"Pet_HatchingPotion_" stringByAppendingString:[self key]];
    }
    return [@"shop_" stringByAppendingString:[self key]];
}
@end
