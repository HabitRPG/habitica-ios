//
//  Customization.m
//  Habitica
//
//  Created by Phillip Thelen on 01/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "Customization.h"
#import "User.h"
#import <SDWebImageManager.h>

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

-(NSString *)getImageNameForUser:(User *)user {
    if ([self.type isEqualToString:@"skin"]) {
        if (user.sleep) {
            return [NSString stringWithFormat:@"skin_%@_sleep", self.name];
        } else {
            return [NSString stringWithFormat:@"skin_%@", self.name];
        }
    } else if ([self.type isEqualToString:@"shirt"]) {
        return [NSString stringWithFormat:@"%@_shirt_%@", user.size, self.name];
    } else if ([self.type isEqualToString:@"hair"]) {
        if ([self.name isEqualToString:@"0"]) {
            return @"head_0";
        }
        if ([self.group isEqualToString:@"color"]) {
            return [NSString stringWithFormat:@"hair_bangs_%@_%@", user.hairBangs, self.name];
        } else if ([self.group isEqualToString:@"flower"]) {
                return [NSString stringWithFormat:@"hair_flower_%@", self.name];
        } else {
            return [NSString stringWithFormat:@"hair_%@_%@_%@", self.group, self.name, user.hairColor];
        }
    }
    return @"";
}

@end
