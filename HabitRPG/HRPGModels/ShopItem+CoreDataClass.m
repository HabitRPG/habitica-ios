//
//  ShopItem+CoreDataClass.m
//  Habitica
//
//  Created by Phillip Thelen on 14/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "ShopItem+CoreDataClass.h"
#import "ShopCategory+CoreDataClass.h"
@implementation ShopItem

- (NSString *)imageName {
    [self willAccessValueForKey:@"imageName"];
    NSString *imageName = [self primitiveValueForKey:@"imageName"];
    [self didAccessValueForKey:@"imageName"];
    if (imageName) {
        return imageName;
    } else if (self.key != nil) {
        return [@"shop_" stringByAppendingString:self.key];
    } else {
        return @"";
    }
}

- (NSString *)readableUnlockCondition {
    if ([self.unlockCondition isEqualToString:@"party invite"]) {
        return NSLocalizedString(@"Invite Friends", nil);
    } else {
        return @"";
    }
}

- (BOOL)canBuy:(NSNumber *)currencyAmount {
    return [currencyAmount floatValue] >= [self.value floatValue] && ![self.locked boolValue];
}

@end
