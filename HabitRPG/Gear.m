//
//  Gear.m
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Gear.h"
#import "User.h"

@implementation Gear

@dynamic con;
@dynamic index;
@dynamic intelligence;
@dynamic klass;
@dynamic per;
@dynamic str;
@dynamic owned;


-(BOOL)isEquippedBy:(User *)user {
    if ([self.type isEqualToString:@"weapon"]) {
        if ([user.equippedWeapon isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"armor"]) {
        if ([user.equippedArmor isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"head"]) {
        if ([user.equippedHead isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"shield"]) {
        if ([user.equippedShield isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"headAccessory"])  {
        if ([user.equippedHeadAccessory isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"back"])  {
        if ([user.equippedBack isEqualToString:self.key]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isCostumeOf:(User *)user {
    if ([self.type isEqualToString:@"weapon"]) {
        if ([user.costumeWeapon isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"armor"]) {
        if ([user.costumeArmor isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"head"]) {
        if ([user.costumeHead isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"shield"]) {
        if ([user.costumeShield isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"headAccessory"])  {
        if ([user.costumeHeadAccessory isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"back"])  {
        if ([user.costumeBack isEqualToString:self.key]) {
            return YES;
        }
    }
    
    return NO;
}

@end
