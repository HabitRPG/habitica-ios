//
//  Customization.m
//  Habitica
//
//  Created by Phillip Thelen on 01/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "Customization.h"
#import "User.h"

@implementation Customization

@dynamic group;
@dynamic name;
@dynamic notes;
@dynamic price;
@dynamic purchased;
@dynamic purchasable;
@dynamic set;
@dynamic text;
@dynamic type;
@dynamic owner;

- (NSString *)getImageNameForUser:(User *)user {
    if ([self.type isEqualToString:@"skin"]) {
        if ([user.preferences.sleep boolValue]) {
            return [NSString stringWithFormat:@"skin_%@_sleep", self.name];
        } else {
            return [NSString stringWithFormat:@"skin_%@", self.name];
        }
    } else if ([self.type isEqualToString:@"shirt"]) {
        return [NSString stringWithFormat:@"%@_shirt_%@", user.preferences.size, self.name];
    } else if ([self.type isEqualToString:@"hair"]) {
        if ([self.name isEqualToString:@"0"]) {
            return @"head_0";
        }
        if ([self.group isEqualToString:@"color"]) {
            if ([user.preferences.hairBangs isEqualToString:@"0"]) {
                return [NSString stringWithFormat:@"hair_bangs_1_%@", self.name];
            } else {
                return [NSString
                    stringWithFormat:@"hair_bangs_%@_%@", user.preferences.hairBangs, self.name];
            }
        } else if ([self.group isEqualToString:@"flower"]) {
            return [NSString stringWithFormat:@"hair_flower_%@", self.name];
        } else {
            return [NSString stringWithFormat:@"hair_%@_%@_%@", self.group, self.name,
                                              user.preferences.hairColor];
        }
    } else if ([self.type isEqualToString:@"background"]) {
        return [NSString stringWithFormat:@"background_%@", self.name];
    }
    return @"";
}

- (NSString *)getPath {
    if ([self.type isEqual:@"hair"]) {
        return [NSString stringWithFormat:@"%@.%@.%@", self.type, self.group, self.name];
    } else {
        return [NSString stringWithFormat:@"%@.%@", self.type, self.name];
    }
}

@end
